import Exception from "@shared/exception";
import { queryTokenList } from "@shared/flow/action/scripts";
import type {
  ExportedTokenInfo,
  TokenList,
  TokenTag,
} from "@shared/flow/entities";
import type { FilterType } from "@shared/flow/enums";
import { exportTokenInfo, isValidFlowAddress } from "@shared/flow/utilitites";
import { executeOrLoadFromRedis } from "@shared/redis";

export async function queryTokenListUsingCache(
  reviewer: string | undefined,
  filter: FilterType,
  pagination?: { page: number; limit: number },
): Promise<TokenList> {
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
  const currentLimit = Math.min(Math.abs(pagination?.limit ?? 100), 1000);

  const tokens: ExportedTokenInfo[] = [];

  let currentPage = Math.max(Math.abs(pagination?.page ?? 0), 0);
  let isAllLoaded = false;

  while (!isAllLoaded) {
    const tokenRequestKey = `token-list/?reviewer=${reviewer}&filter=${filter}&page=${currentPage}&limit=${currentLimit}`;
    const ret = await executeOrLoadFromRedis(
      tokenRequestKey,
      queryTokenList(currentPage, currentLimit, reviewer, filter),
    );
    tokens.push(
      ...(ret.list
        .map(exportTokenInfo)
        .filter((x) => x !== undefined) as ExportedTokenInfo[]),
    );
    if (isLoadAll && ret.list.length !== 0) {
      currentPage += 1;
    } else {
      isAllLoaded = true;
    }
  }

  // Add default tags
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
    "lp-token": {
      name: "lp-token",
      description: "Asset representing liquidity provider token",
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

  // return the token list
  return {
    name: "Flow Token List",
    logoURI:
      "https://cdn.jsdelivr.net/gh/FlowFans/flow-token-list@main/token-registry/A.1654653399040a61.FlowToken/logo.svg",
    keywords: [
      "Flow",
      "Cadence",
      "EVM",
      "DeFi",
      "NFT",
      "FT",
      "Dapp",
      "Blockchain",
      "Crypto",
    ],
    tags: defaultTags,
    timestamp: new Date(),
    tokens,
    version: {
      major: 1,
      minor: 0,
      patch: 0,
    },
  };
}
