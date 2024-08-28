import type { FlowService } from "@shared/flow/flow.service";
import type { InjectionKey } from "vue";
import type {
  ExportedNFTCollectionInfo,
  ExportedTokenInfo,
  StandardNFTCollectionView,
  StandardTokenView,
  TagableItem,
} from "./entities";
import { EvaluationType } from "./enums";
import appInfo from "@shared/config/info";

/**
 * Injection key for FlowService
 */
export const FlowSrvKey = Symbol("flowSrv") as InjectionKey<FlowService>;

/**
 * Check if the address is a valid Flow address
 */
export function isValidFlowAddress(addr: string) {
  const regExp = /^0x[a-fA-F0-9]{16}$/gi;
  return regExp.test(addr);
}

/**
 * Parse the review data from the token view
 */
export function parseReviewData(item: TagableItem): {
  rank: EvaluationType;
  tags: string[];
} {
  const data = {
    rank: EvaluationType.UNVERIFIED,
    tags: [] as string[],
  };
  const tags = new Set(item?.tags ?? []);
  if (tags.has("Featured")) {
    data.rank = EvaluationType.FEATURED;
    tags.delete("Featured");
    tags.delete("Verified");
  } else if (tags.has("Verified")) {
    data.rank = EvaluationType.VERIFIED;
    tags.delete("Verified");
  } else if (tags.has("Pending")) {
    data.rank = EvaluationType.PENDING;
    tags.delete("Pending");
  }
  data.tags = Array.from(tags);
  return data;
}

/**
 * Export ft info to a standard TokenList format
 * @param ft
 */
export function exportTokenInfo(
  ft: StandardTokenView,
): ExportedTokenInfo | undefined {
  if (ft.path === undefined) {
    return undefined;
  }
  if (ft.display === undefined) {
    return undefined;
  }
  const extensions: Record<string, string> = ft.display?.display?.social ?? {};
  if (typeof ft.display.display.externalURL === "string") {
    extensions["website"] = ft.display.display.externalURL;
  }
  if (typeof ft.display.source === "string") {
    extensions["displaySource"] = ft.display.source;
  }
  if (typeof ft.dataSource === "string") {
    extensions["pathSource"] = ft.dataSource;
  }
  return {
    chainId: appInfo.chainId,
    address: ft.identity.address,
    contractName: ft.identity.contractName,
    path: ft.path,
    evmAddress: undefined, // TODO: add EVM address from View
    symbol: ft.display.display.symbol,
    name: ft.display.display.name,
    description: ft.display?.display?.description ?? "",
    decimals: ft.decimals,
    logoURI: ft.display.display.logos[0].uri,
    tags: ft.tags ?? [],
    extensions,
  };
}

export function exportNFTCollectionInfo(
  nft: StandardNFTCollectionView,
): ExportedNFTCollectionInfo | undefined {
  if (nft.paths === undefined) {
    return undefined;
  }
  if (nft.display === undefined) {
    return undefined;
  }
  const extensions: Record<string, string> = nft.display?.display?.social ?? {};
  if (typeof nft.display.display.externalURL === "string") {
    extensions["website"] = nft.display.display.externalURL;
  }
  if (typeof nft.display.source === "string") {
    extensions["displaySource"] = nft.display.source;
  }
  return {
    chainId: appInfo.chainId,
    address: nft.identity.address,
    contractName: nft.identity.contractName,
    path: nft.paths,
    evmAddress: undefined, // TODO: add EVM address from View
    name: nft.display.display.name,
    description: nft.display?.display?.description ?? "",
    logoURI: nft.display.display.squareImage.uri,
    bannerURI: nft.display.display.bannerImage.uri,
    tags: nft.tags ?? [],
    extensions,
  };
}
