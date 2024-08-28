import type {
  AddressStatus,
  Media,
  NFTCollectionDisplay,
  NFTListQueryResult,
  NFTPaths,
  NFTStatus,
  ReviewerInfo,
  StandardNFTCollectionView,
  StandardTokenView,
  TokenDisplay,
  TokenIdentity,
  TokenPaths,
  TokenQueryResult,
  TokenStatus,
} from "@shared/flow/entities";
import { FilterType } from "@shared/flow/enums";
// import type { FlowService } from "../flow.service";
import { getFlowInstance } from "../flow.service.factory";
// Scripts - Utils
import scResolveName from "@cadence/scripts/utils/resolve-name.cdc?raw";
import scGetContractNames from "@cadence/scripts/get-contract-names.cdc?raw";
// Scripts - FTs
import scIsTokenRegistered from "@cadence/scripts/is-token-registered.cdc?raw";
import scGetFTContracts from "@cadence/scripts/get-ft-contracts.cdc?raw";
import scGetFTContractStatus from "@cadence/scripts/get-ft-contract-status.cdc?raw";
import scGetReviewerInfo from "@cadence/scripts/get-reviewer-info.cdc?raw";
import scGetReviewers from "@cadence/scripts/get-reviewers.cdc?raw";
import scGetVeifiedReviewers from "@cadence/scripts/get-verified-reviewers.cdc?raw";
import scGetAddressReviewerStatus from "@cadence/scripts/get-address-reviewer-status.cdc?raw";
import scQueryTokenList from "@cadence/scripts/query-token-list.cdc?raw";
import scQueryTokenListByAddress from "@cadence/scripts/query-token-list-by-address.cdc?raw";
// Scripts - NFTs
import scIsNFTRegistered from "@cadence/scripts/nftlist/is-token-registered.cdc?raw";
import scGetNFTContracts from "@cadence/scripts/nftlist/get-nft-contracts.cdc?raw";
import scGetNFTContractStatus from "@cadence/scripts/nftlist/get-nft-contract-status.cdc?raw";
import scGetNFTListReviewerInfo from "@cadence/scripts/nftlist/get-reviewer-info.cdc?raw";
import scGetNFTListReviewers from "@cadence/scripts/nftlist/get-reviewers.cdc?raw";
import scGetNFTListVeifiedReviewers from "@cadence/scripts/nftlist/get-verified-reviewers.cdc?raw";
import scGetNFTListAddressReviewerStatus from "@cadence/scripts/nftlist/get-address-reviewer-status.cdc?raw";
import scQueryNFTList from "@cadence/scripts/nftlist/query-token-list.cdc?raw";
import scQueryNFTListByAddress from "@cadence/scripts/nftlist/query-token-list-by-address.cdc?raw";

/** ---- Scripts ---- */

/**
 * Resolve address name
 */
export async function resolveAddressName(addr: string): Promise<string> {
  const flowSrv = await getFlowInstance();
  if (flowSrv.network !== "mainnet") {
    return addr;
  }
  const ret = await flowSrv.executeScript(
    scResolveName,
    (arg, t) => [arg(addr, t.Address)],
    addr,
  );
  return ret ?? addr;
}

/**
 * check if the token is registered
 */
export async function isTokenRegistered(ft: TokenIdentity): Promise<boolean> {
  const flowServ = await getFlowInstance();
  return await flowServ.executeScript(
    scIsTokenRegistered,
    (arg, t) => [arg(ft.address, t.Address), arg(ft.contractName, t.String)],
    false,
  );
}

function parseFTContractStatus(obj: any): TokenStatus {
  const paths: Record<string, string> = {};
  // add alias for balance and receiver
  for (let key in obj.publicPaths) {
    paths[key] = obj.publicPaths[key];
  }
  return {
    address: obj.address,
    contractName: obj.contractName,
    isRegistered: obj.isRegistered,
    isRegisteredWithNativeViewResolver: obj.isRegisteredWithNativeViewResolver,
    isWithDisplay: obj.isWithDisplay,
    isWithVaultData: obj.isWithVaultData,
    vaultPath: obj.vaultPath,
    publicPaths: paths,
  };
}

export async function getContractNames(address: string): Promise<string[]> {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetContractNames,
    (arg, t) => [arg(address, t.Address)],
    [],
  );
  return ret;
}

/**
 * Get the FT contracts
 */
export async function getFTContracts(address: string): Promise<TokenStatus[]> {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetFTContracts,
    (arg, t) => [arg(address, t.Address)],
    [],
  );
  return ret.map(parseFTContractStatus);
}

/**
 * Get the FT contract status
 * @param address
 * @param contractName
 */
export async function getFTContractStatus(
  address: string,
  contractName: string,
  extraVaultAddr: string | null = null,
): Promise<TokenStatus | null> {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetFTContractStatus,
    (arg, t) => [
      arg(address, t.Address),
      arg(contractName, t.String),
      arg(extraVaultAddr, t.Optional(t.Address)),
    ],
    null,
  );
  return ret ? parseFTContractStatus(ret) : null;
}

/**
 * Get the address status
 */
export async function getAddressReviewerStatus(
  address: string,
): Promise<AddressStatus> {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetAddressReviewerStatus,
    (arg, t) => [arg(address, t.Address)],
    {} as any,
  );
  return {
    isReviewer: ret?.isReviewer ?? false,
    isPendingToClaimReviewMaintainer:
      ret?.isPendingToClaimReviewMaintainer ?? false,
    isReviewMaintainer: ret?.isReviewMaintainer ?? false,
    reviewerAddr: ret?.reviewerAddr,
  };
}

const parseReviewer = (obj: any): ReviewerInfo => {
  return {
    address: obj.address,
    verified: obj.verified ?? false,
    name: obj.name,
    url: obj.url,
    managedTokenAmt: parseInt(obj.managedTokenAmt),
    reviewedTokenAmt: parseInt(obj.reviewedTokenAmt),
    customziedTokenAmt: parseInt(obj.customziedTokenAmt),
  };
};

export async function getReviewers() {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetReviewers,
    (_arg, _t) => [],
    [],
  );
  return ret.map(parseReviewer).sort((a, b) => {
    // Prioritize verified, desc by customziedTokenAmt
    if (a.verified && !b.verified) return -1;
    if (!a.verified && b.verified) return 1;
    return b.customziedTokenAmt - a.customziedTokenAmt;
  });
}

export async function getVerifiedReviewers() {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetVeifiedReviewers,
    (_arg, _t) => [],
    [],
  );
  return ret.map(parseReviewer).sort((a, b) => {
    return b.customziedTokenAmt - a.customziedTokenAmt;
  });
}

/**
 * Get the reviewer info
 * @param flowServ
 * @param address
 */
export async function getReviewerInfo(address: string) {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetReviewerInfo,
    (arg, t) => [arg(address, t.Address)],
    null,
  );
  return ret ? parseReviewer(ret) : null;
}

const parseTokenPaths = (obj: any): TokenPaths => {
  return {
    vault: obj.vaultPath
      ? `/${obj.vaultPath.domain}/${obj.vaultPath.identifier}`
      : "",
    receiver: obj.receiverPath
      ? `/${obj.receiverPath.domain}/${obj.receiverPath.identifier}`
      : "",
    balance: obj.balancePath
      ? `/${obj.balancePath.domain}/${obj.balancePath.identifier}`
      : "",
  };
};

const parseURL = (file: any): string => {
  if (!file) {
    return "";
  }
  let url = "";
  if (file.url) {
    url = file.url;
  } else if (file.cid) {
    url = `https://ipfs.io/ipfs/${file.cid}`;
  }
  return url;
};

const parseMedia = (obj: any): Media => {
  return {
    type: obj.mediaType,
    uri: parseURL(obj.file),
  };
};

const parseTokenDisplay = (obj: any): TokenDisplay => {
  const social: Record<string, string> = {};
  for (const key in obj.socials) {
    social[key] = parseURL(obj.socials[key]);
  }
  return {
    name: obj.name,
    symbol: obj.symbol,
    description: obj.description,
    externalURL: parseURL(obj.externalURL),
    logos: obj.logos?.items?.map(parseMedia) ?? [],
    social,
  };
};

const parseTokenView = (obj: any): StandardTokenView => {
  const ret = {
    identity: {
      address: obj.identity.address,
      contractName: obj.identity.contractName,
      isWithDisplay: !!obj.display,
      isWithVaultData: !!obj.paths,
    },
    decimals: parseInt(obj.decimals),
    tags: obj.tags,
    dataSource: obj.dataSource,
    path: obj.paths ? parseTokenPaths(obj.paths) : undefined,
    display: obj.display
      ? {
          source: obj.display.source,
          display: parseTokenDisplay(obj.display.display),
        }
      : undefined,
  };
  return ret;
};

/**
 * Query token list by address
 */
export async function queryTokenListByAddress(
  address: string,
  reviewer?: string,
): Promise<TokenQueryResult> {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scQueryTokenListByAddress,
    (arg, t) => [arg(address, t.Address), arg(reviewer, t.Optional(t.Address))],
    { total: "0", list: [] },
  );
  return {
    total: parseInt(ret.total),
    list: ret.list.map(parseTokenView),
  };
}

/**
 * Query token list
 */
export async function queryTokenList(
  page: number,
  limit: number,
  reviewer?: string,
  filter: FilterType = FilterType.ALL,
): Promise<TokenQueryResult> {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scQueryTokenList,
    (arg, t) => [
      arg(page.toFixed(0), t.Int),
      arg(limit.toFixed(0), t.Int),
      arg(reviewer, t.Optional(t.Address)),
      arg(filter?.toString(), t.Optional(t.UInt8)),
    ],
    { total: "0", list: [] },
  );
  return {
    total: parseInt(ret.total),
    list: ret.list.map(parseTokenView).sort((a, b) => {
      // Featured first, then Verified, then by contract name
      if (a.tags.includes("Featured") && !b.tags.includes("Featured"))
        return -1;
      if (!a.tags.includes("Featured") && b.tags.includes("Featured")) return 1;
      if (a.tags.includes("Verified") && !b.tags.includes("Verified"))
        return -1;
      if (!a.tags.includes("Verified") && b.tags.includes("Verified")) return 1;
      return a.identity.contractName.localeCompare(b.identity.contractName);
    }),
  };
}

/// --- NFT List ---

export async function isNFTRegistered(id: TokenIdentity): Promise<boolean> {
  const flowServ = await getFlowInstance();
  return await flowServ.executeScript(
    scIsNFTRegistered,
    (arg, t) => [arg(id.address, t.Address), arg(id.contractName, t.String)],
    false,
  );
}

function parseNFTContractStatus(obj: any): NFTStatus {
  return {
    address: obj.address,
    contractName: obj.contractName,
    isRegistered: obj.isRegistered,
    isWithDisplay: obj.isWithDisplay,
    isWithVaultData: true,
    storage: obj.storagePath,
    public: obj.publicPath,
  };
}

export async function getNFTContracts(address: string) {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetNFTContracts,
    (arg, t) => [arg(address, t.Address)],
    [],
  );
  return ret.map(parseNFTContractStatus);
}

export async function getNFTContractStatus(
  address: string,
  contractName: string,
  collectionOwnerAddr: string | null = null,
): Promise<NFTStatus | null> {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetNFTContractStatus,
    (arg, t) => [
      arg(address, t.Address),
      arg(contractName, t.String),
      arg(collectionOwnerAddr, t.Optional(t.Address)),
    ],
    null,
  );
  return ret ? parseNFTContractStatus(ret) : null;
}

export async function getNFTListReviewerInfo(address: string) {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetNFTListReviewerInfo,
    (arg, t) => [arg(address, t.Address)],
    null,
  );
  return ret ? parseReviewer(ret) : null;
}

export async function getNFTListReviewers() {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetNFTListReviewers,
    (_arg, _t) => [],
    [],
  );
  return ret.map(parseReviewer).sort((a, b) => {
    // Prioritize verified, desc by customziedTokenAmt
    if (a.verified && !b.verified) return -1;
    if (!a.verified && b.verified) return 1;
    return b.customziedTokenAmt - a.customziedTokenAmt;
  });
}

export async function getVerifiedNFTListReviewers() {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetNFTListVeifiedReviewers,
    (_arg, _t) => [],
    [],
  );
  return ret.map(parseReviewer).sort((a, b) => {
    return b.customziedTokenAmt - a.customziedTokenAmt;
  });
}

export async function getNFTListAddressReviewerStatus(address: string) {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scGetNFTListAddressReviewerStatus,
    (arg, t) => [arg(address, t.Address)],
    {} as any,
  );
  return {
    isReviewer: ret?.isReviewer ?? false,
    isPendingToClaimReviewMaintainer:
      ret?.isPendingToClaimReviewMaintainer ?? false,
    isReviewMaintainer: ret?.isReviewMaintainer ?? false,
    reviewerAddr: ret?.reviewerAddr,
  };
}

const parseNFTCollectionDisplay = (obj: any): NFTCollectionDisplay => {
  const social: Record<string, string> = {};
  for (const key in obj.socials) {
    social[key] = parseURL(obj.socials[key]);
  }
  return {
    name: obj.name,
    description: obj.description,
    externalURL: parseURL(obj.externalURL),
    squareImage: parseMedia(obj.squareImage),
    bannerImage: parseMedia(obj.bannerImage),
    social,
  };
};

const parseNFTCollectionPaths = (paths: any): NFTPaths => {
  return {
    storage: paths.storagePath
      ? `/${paths.storagePath.domain}/${paths.storagePath.identifier}`
      : "",
    public: paths.publicPath
      ? `/${paths.publicPath.domain}/${paths.publicPath.identifier}`
      : "",
  };
};

function parseNFTCollectionView(obj: any): StandardNFTCollectionView {
  return {
    identity: {
      address: obj.identity.address,
      contractName: obj.identity.contractName,
      isWithDisplay: !!obj.display,
      isWithVaultData: true,
    },
    tags: obj.tags,
    paths: parseNFTCollectionPaths(obj.paths),
    display: obj.display
      ? {
          source: obj.display.source,
          display: parseNFTCollectionDisplay(obj.display.display),
        }
      : undefined,
  };
}

export async function queryNFTListByAddress(
  address: string,
  reviewer?: string,
): Promise<NFTListQueryResult> {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scQueryNFTListByAddress,
    (arg, t) => [arg(address, t.Address), arg(reviewer, t.Optional(t.Address))],
    { total: "0", list: [] },
  );
  return {
    total: parseInt(ret.total),
    list: ret.list.map(parseNFTCollectionView),
  };
}

export async function queryNFTList(
  page: number,
  limit: number,
  reviewer?: string,
  filter: FilterType = FilterType.ALL,
): Promise<NFTListQueryResult> {
  const flowServ = await getFlowInstance();
  const ret = await flowServ.executeScript(
    scQueryNFTList,
    (arg, t) => [
      arg(page.toFixed(0), t.Int),
      arg(limit.toFixed(0), t.Int),
      arg(reviewer, t.Optional(t.Address)),
      arg(filter?.toString(), t.Optional(t.UInt8)),
    ],
    { total: "0", list: [] },
  );
  return {
    total: parseInt(ret.total),
    list: ret.list.map(parseNFTCollectionView).sort((a, b) => {
      // Featured first, then Verified, then by contract name
      if (a.tags.includes("Featured") && !b.tags.includes("Featured"))
        return -1;
      if (!a.tags.includes("Featured") && b.tags.includes("Featured")) return 1;
      if (a.tags.includes("Verified") && !b.tags.includes("Verified"))
        return -1;
      if (!a.tags.includes("Verified") && b.tags.includes("Verified")) return 1;
      return a.identity.contractName.localeCompare(b.identity.contractName);
    }),
  };
}
