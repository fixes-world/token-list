import Exception from "@shared/exception";

/**
 * Send a POST request to the given URL
 */
export async function sendPostRequest(
  baseUrl: string | undefined,
  path: string,
  headers?: Record<string, string>,
  body?: any,
  bodyUseForm: boolean = false,
) {
  return await sendRequest(
    baseUrl,
    path,
    "POST",
    headers ?? {},
    body ?? {},
    bodyUseForm,
  );
}

/**
 * Send a GET request to the given URL
 */
export async function sendGetRequest(
  baseUrl: string | undefined,
  path: string,
  headers?: Record<string, string>,
) {
  return await sendRequest(baseUrl, path, "GET", headers ?? {});
}

/**
 * Send a POST request to the given URL
 */
export async function sendRequest(
  baseUrl: string | undefined,
  path: string,
  method: "GET" | "POST",
  headers: Record<string, string>,
  body?: any,
  bodyUseForm: boolean = false,
) {
  const purePath = path.startsWith("/") ? path.substring(1) : path;

  const hasBody = method === "POST" && body !== undefined;
  const mergedHeaders = Object.assign({}, headers);
  let bodyStr = undefined;
  if (hasBody) {
    if (bodyUseForm) {
      mergedHeaders["Content-Type"] = "application/x-www-form-urlencoded";
      const params = new URLSearchParams();
      for (const key in body) {
        params.append(key, body[key]);
      }
      bodyStr = params.toString();
    } else {
      mergedHeaders["Content-Type"] = "application/json";
      bodyStr = JSON.stringify(body);
    }
  }

  let res: Response | undefined = undefined;
  let errorMessages: string | undefined = undefined;
  let resStatus: number;
  try {
    const fullUrl = baseUrl
      ? new URL(purePath, baseUrl).toString()
      : purePath.startsWith("http")
        ? purePath
        : `/${purePath}`;
    console.log(`Sending ${method} request to ${fullUrl}`);
    res = await fetch(fullUrl, {
      method,
      headers: mergedHeaders,
      body: bodyStr,
    });
    resStatus = res.status;
  } catch (err: any) {
    resStatus = err.status ?? 500;
    errorMessages = err.message;
    console.error(`Failed to send request to ${path}`, err);
  }

  let result: any;
  try {
    result = await res?.json();
  } catch (e: any) {
    throw new Exception(
      500,
      `Failed to parse response from ${path}: ${e.message}`,
    );
  }
  if (resStatus >= 200 && resStatus < 300) {
    // check if the response is an error
    if (!result?.success && typeof result?.error === "object") {
      throw new Exception(result.error.code, result.error.message);
    }
    return result;
  } else {
    errorMessages = errorMessages ?? JSON.stringify(result ?? "unknown error");
    throw new Exception(
      resStatus,
      `Failed to send request to ${path}. Error: ${errorMessages}`,
    );
  }
}

/**
 * APIs Builder
 */
export function createRequestBuilder(
  baseURL: string,
  accessToken: string,
  defaultHeaders: Record<string, string> = {},
) {
  return (uri: string, method: "GET" | "POST" = "GET") => {
    return async (
      opts: {
        query?: { [key: string]: any };
        params?: { [key: string]: any };
        body?: any;
      } = {},
    ): Promise<any> => {
      let mergedUri = uri.startsWith("/") ? uri.substring(1) : uri;
      if (typeof opts.params === "object") {
        for (const key in opts.params) {
          mergedUri = mergedUri.replaceAll(`:${key}`, opts.params[key]);
        }
      }
      const url = new URL(mergedUri, baseURL);
      if (typeof opts.query === "object") {
        for (const key in opts.query) {
          url.searchParams.append(key, opts.query[key]);
        }
      }
      return await sendRequest(
        undefined,
        url.toString(),
        method,
        Object.assign(
          defaultHeaders,
          accessToken
            ? {
                Authorization: `Bearer ${accessToken}`,
              }
            : {},
        ),
        opts.body,
      );
    };
  };
}
