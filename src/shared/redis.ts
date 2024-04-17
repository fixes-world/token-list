import { kv } from "@vercel/kv";
import appInfo from "@shared/config/info";

const appKey = "TokenListAPI";

const isRedisCacheEnabled =
  import.meta.env.KV_REST_API_URL && import.meta.env.KV_REST_API_TOKEN;

function getCacheKey(methodKey: string) {
  return `${appKey}:SERVICE_CACHE:${appInfo.network}:KEY_VALUE:${methodKey}`;
}

export function getRequestURLKey(request: Request) {
  const reqUrl = new URL(request.url);
  const path = reqUrl.pathname;
  const query = encodeURIComponent(reqUrl.searchParams.toString());
  return `/${path}` + (query ? `?${query}` : "");
}

export async function loadRedisCached(methodKey: string) {
  if (!isRedisCacheEnabled) return null;

  const redisKey = getCacheKey(methodKey);
  console.log("Request RedisKey - ", redisKey);
  let cachedResult: string | null = null;
  try {
    cachedResult = await kv.get<string>(redisKey);
    if (cachedResult) {
      console.log("Request loaded from RedisCached - ", redisKey);
    } else {
      console.log("Request not found in RedisCache.");
    }
  } catch (e) {
    console.error("Failed to load cached result: ", e);
  }
  return cachedResult;
}

export async function executeOrLoadFromRedis<T>(
  methodKey: string,
  methodPromise: Promise<T>,
  ttl?: number,
): Promise<T> {
  if (!isRedisCacheEnabled) return await methodPromise;

  const cachedResult = await loadRedisCached(methodKey);

  let result: T;
  if (!cachedResult) {
    result = await methodPromise;
    const ttlValue = ttl ?? 60;
    await kv.set<string>(
      getCacheKey(methodKey),
      typeof result === "string" ? result : JSON.stringify(result),
      {
        ex: ttlValue,
      } /* ex: 1 min cache for all GET method with same methodKey */,
    );
  } else {
    try {
      result = JSON.parse(cachedResult) as T;
    } catch (err) {
      result = cachedResult as T;
    }
  }
  return result;
}

function getIndexPoolKey(address: string) {
  return `${appKey}:SERVICE_POOL:${appInfo.network}:ADDRESS:${address}`;
}

export async function acquireKeyIndex(
  address: string,
  totalKeyAmt: number,
  ttl?: number,
): Promise<number> {
  if (!isRedisCacheEnabled) return Math.floor(Math.random() * totalKeyAmt);

  const indexPoolKey = getIndexPoolKey(address);
  const redisTotalAmountKey = `${indexPoolKey}:KEY_VALUE`;
  const redisKeyPool = `${indexPoolKey}:SORTED_SET`;

  const now = Date.now();
  const timeout = now + (ttl ?? 1000 * 60);
  const pair = await kv.zpopmin<string>(redisKeyPool, 1);
  if (pair && pair.length === 2) {
    const [key, score] = pair;
    // set a timeout for key
    await kv.zadd(redisKeyPool, {
      member: key,
      score: timeout,
    });
    if (now - parseInt(score) >= 0) {
      // return key index
      return parseInt(key);
    }
  }
  // Need a new Key, check if reach max key?
  const currentKeyAmtStr = await kv.get<string>(redisTotalAmountKey);
  const currentKeyAmt = parseInt(currentKeyAmtStr ?? "0");
  if (totalKeyAmt > currentKeyAmt) {
    const p = kv.pipeline();
    p.incr(redisTotalAmountKey);
    p.zadd(redisKeyPool, {
      member: currentKeyAmt.toString(),
      score: timeout,
    });
    await p.exec();
    // return current max key index
    return currentKeyAmt;
  } else {
    throw new Error("Reach max key amount.");
  }
}

export async function releaseKeyIndex(address: string, keyIndex: number) {
  if (!isRedisCacheEnabled) return;

  const indexPoolKey = getIndexPoolKey(address);
  const redisKeyPool = `${indexPoolKey}:SORTED_SET`;

  // set a timeout for key
  await kv.zadd(redisKeyPool, {
    member: keyIndex.toString(),
    score: Date.now(),
  });
}
