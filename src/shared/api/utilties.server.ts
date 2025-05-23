import Exception from "@shared/exception";
import {
  getReviewers,
  getNFTListReviewers,
  queryTokenList,
  queryNFTList,
  queryEVMBridgedFTList,
  queryEVMBridgedNFTList,
} from "@shared/flow/action/scripts";
import type {
  ExportedNFTCollectionInfo,
  ExportedTokenInfo,
  NFTList,
  QueryResult,
  ReviewerInfo,
  TokenList,
  TokenTag,
} from "@shared/flow/entities";
import { FilterType } from "@shared/flow/enums";
import {
  exportNFTCollectionInfo,
  exportTokenInfo,
  isValidFlowAddress,
} from "@shared/flow/utilitites";
import { executeOrLoadFromRedis } from "@shared/redis";
import qiniu from "qiniu";
import appInfo from "@shared/config/info";
import runtime from "@shared/config/runtime";

export function generateQiniuUploadToken(): string {
  const accessKey = runtime.secrets.qiniu.accessKey;
  const secretKey = runtime.secrets.qiniu.secretKey;
  if (!accessKey || !secretKey) {
    throw new Exception(500, "QINIU_ACCESS_KEY or QINIU_SECRET_KEY is not set");
  }
  const mac = new qiniu.auth.digest.Mac(accessKey, secretKey);
  const putPolicy = new qiniu.rs.PutPolicy({
    scope: runtime.secrets.qiniu.bucket ?? "fixes-world",
    returnBody:
      '{"key": $(key), "hash": $(etag), "bucket": $(bucket), "mimeType": $(mimeType), "fsize": $(fsize)}',
  });
  return putPolicy.uploadToken(mac);
}

export async function queryReviewersUsingCache(): Promise<ReviewerInfo[]> {
  const reviewersRequestKey = "reviewers/";
  const cacheTime = 60 * 60; // 1 hours
  const ret = await executeOrLoadFromRedis(
    reviewersRequestKey,
    getReviewers,
    cacheTime,
  );
  return ret;
}

export async function queryReviewersForNFTListUsingCache(): Promise<
  ReviewerInfo[]
> {
  const reviewersRequestKey = "reviewers-for-nftlist/";
  const cacheTime = 60 * 60; // 1 hours
  const ret = await executeOrLoadFromRedis(
    reviewersRequestKey,
    getNFTListReviewers,
    cacheTime,
  );
  return ret;
}

const defaultTags: Record<string, TokenTag> = {
  stablecoin: {
    name: "stablecoin",
    description:
      "Tokens that are fixed to an external asset, e.g. the US dollar",
  },
  ethereum: {
    name: "ethereum",
    description: "Asset bridged from ethereum",
  },
  "wrapped-celer": {
    name: "wrapped-celer",
    description: "Asset wrapped using celer bridge",
  },
  "utility-token": {
    name: "utility-token",
    description:
      "Tokens that are designed to be spent within a certain blockchain ecosystem",
  },
  "governance-token": {
    name: "governance-token",
    description:
      "Tokens that are designed to be use in community governance and maintenance",
  },
  memecoin: {
    name: "memecoin",
    description: "Tokens that are created for fun and meme",
  },
};

const defaultKeywords = [
  "Flow",
  "Cadence",
  "EVM",
  "DeFi",
  "NFT",
  "FT",
  "Dapp",
  "Blockchain",
  "Crypto",
];

export async function queryTokenListUsingCache(
  reviewer: string | undefined,
  filter: FilterType,
  isEVMOnly: boolean,
  pagination?: { page: number; limit: number },
): Promise<TokenList> {
  const tokens = await queryTokenListGeneric(
    "token-list",
    isEVMOnly,
    !isEVMOnly ? queryTokenList : queryEVMBridgedFTList,
    exportTokenInfo,
    reviewer,
    filter,
    pagination,
  );

  // return the token list
  return {
    name: "Flow Token List",
    network: appInfo.network,
    chainId: appInfo.chainId,
    tokens: tokens.filter((x) => x !== undefined) as ExportedTokenInfo[],
    totalAmount: tokens.length,
    filterType: FilterType[filter],
    timestamp: new Date(),
    logoURI:
      "https://cdn.jsdelivr.net/gh/FlowFans/flow-token-list@main/token-registry/A.1654653399040a61.FlowToken/logo.svg",
    keywords: defaultKeywords,
    tags: defaultTags,
    version: {
      major: 1,
      minor: 0,
      patch: 0,
    },
  };
}

export async function queryNFTListUsingCache(
  reviewer: string | undefined,
  filter: FilterType,
  isEVMOnly: boolean,
  pagination?: { page: number; limit: number },
): Promise<NFTList> {
  const tokens = await queryTokenListGeneric(
    "nft-list",
    isEVMOnly,
    !isEVMOnly ? queryNFTList : queryEVMBridgedNFTList,
    exportNFTCollectionInfo,
    reviewer,
    filter,
    pagination,
  );
  // return the token list
  return {
    name: "Flow NFT List",
    network: appInfo.network,
    chainId: appInfo.chainId,
    tokens: tokens.filter(
      (x) => x !== undefined,
    ) as ExportedNFTCollectionInfo[],
    totalAmount: tokens.length,
    filterType: FilterType[filter],
    timestamp: new Date(),
    tags: defaultTags,
    version: {
      major: 1,
      minor: 0,
      patch: 0,
    },
  };
}

async function queryTokenListGeneric<T, R>(
  apiName: string,
  isEVMOnly: boolean,
  queryListFunc: (
    page: number,
    limit: number,
    reviewer?: string,
    filter?: FilterType,
  ) => Promise<QueryResult<T>>,
  parseTokenFunc: (isEVMList: boolean, token: T) => R,
  reviewer: string | undefined,
  filter: FilterType,
  pagination?: { page: number; limit: number },
): Promise<R[]> {
  // Ensure the reviewer address is valid
  if (typeof reviewer === "string") {
    if (!isValidFlowAddress(reviewer)) {
      throw new Exception(400, "The reviewer address is invalid");
    }
  }
  // Ensure the filter is valid
  if (isNaN(filter) || filter < 0 || filter > 4) {
    throw new Exception(400, "The filter type is invalid");
  }

  const isLoadAll = pagination === undefined;
  const currentLimit = isEVMOnly
    ? Math.min(Math.abs(pagination?.limit ?? 15), 30)
    : Math.min(Math.abs(pagination?.limit ?? 50), 200);

  const tokens: R[] = [];

  let currentPage = Math.max(Math.abs(pagination?.page ?? 0), 0);
  let isAllLoaded = false;
  let totalAmount = -1;

  while (!isAllLoaded) {
    const tokenRequestKey = `${apiName}/?reviewer=${reviewer}&filter=${filter}&page=${currentPage}&limit=${currentLimit}`;
    const ret =
      appInfo.network === "mainnet"
        ? await executeOrLoadFromRedis(
            tokenRequestKey,
            queryListFunc.bind(
              null,
              currentPage,
              currentLimit,
              reviewer,
              filter,
            ),
          )
        : await queryListFunc(currentPage, currentLimit, reviewer, filter);
    if (ret.total === 0) {
      break;
    }
    if (totalAmount === -1) {
      totalAmount = ret.total;
    }
    tokens.push(
      ...ret.list
        .map(parseTokenFunc.bind(null, isEVMOnly))
        .filter((x) => x !== undefined),
    );
    if (isLoadAll && ret.list.length !== 0) {
      currentPage += 1;
    } else {
      isAllLoaded = true;
    }
  }
  if (tokens.length === 0) {
    throw new Exception(404, "No token found");
  }
  return tokens;
}
