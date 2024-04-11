import type {
  AddressStatus,
  Media,
  ReviewerInfo,
  StandardTokenView,
  TokenDisplay,
  TokenIdentity,
  TokenPaths,
  TokenQueryResult,
} from "@shared/flow/entities";
import { EvaluationType, FilterType } from "@shared/flow/enums";
import type { FlowService } from "../flow.service";
// import { } from "../utilitites";
import appInfo from "@shared/config/info";
// Scripts
import scGetReviewers from "@cadence/scripts/get-reviewers.cdc?raw";
import scGetVeifiedReviewers from "@cadence/scripts/get-verified-reviewers.cdc?raw";
import scIsTokenRegistered from "@cadence/scripts/is-token-registered.cdc?raw";
import scGetAddressReviewerStatus from "@cadence/scripts/get-address-reviewer-status.cdc?raw";
import scQueryTokenList from "@cadence/scripts/query-token-list.cdc?raw";
import scQueryTokenListByAddress from "@cadence/scripts/query-token-list-by-address.cdc?raw";

/** ---- Scripts ---- */

/**
 * check if the token is registered
 */
export async function isTokenRegistered(
  flowServ: FlowService,
  ft: TokenIdentity
): Promise<boolean> {
  return await flowServ.executeScript(
    scIsTokenRegistered,
    (arg, t) => [arg(ft.address, t.Address), arg(ft.contractName, t.String)],
    false
  );
}

/**
 * Get the address status
 */
export async function getAddressReviewerStatus(
  flowServ: FlowService,
  address: string
): Promise<AddressStatus> {
  const ret = await flowServ.executeScript(
    scGetAddressReviewerStatus,
    (arg, t) => [arg(address, t.Address)],
    {} as any
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

export async function getReviewers(flowServ: FlowService) {
  const ret = await flowServ.executeScript(scGetReviewers, (arg, t) => [], []);
  return ret.map(parseReviewer);
}

export async function getVerifiedReviewers(flowServ: FlowService) {
  const ret = await flowServ.executeScript(
    scGetVeifiedReviewers,
    (arg, t) => [],
    []
  );
  return ret.map(parseReviewer);
}

const parseTokenPaths = (obj: any): TokenPaths => {
  return {
    vault: obj.vault,
    receiver: obj.receiver,
    balance: obj.balance,
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
  for (const key in obj.social) {
    social[key] = parseURL(obj.social[key]);
  }
  return {
    name: obj.name,
    symbol: obj.symbol,
    description: obj.description,
    externalURL: obj.externalURL,
    logos: obj.logos?.items?.map(parseMedia) ?? [],
    social,
  };
};

const parseTokenView = (obj: any): StandardTokenView => {
  return {
    identity: {
      address: obj.identity.address,
      contractName: obj.identity.contractName,
    },
    decimals: parseInt(obj.decimals),
    tags: obj.tags,
    path: obj.paths ? parseTokenPaths(obj.paths) : undefined,
    display: obj.display ? parseTokenDisplay(obj.display) : undefined,
  };
};

/**
 * Query token list by address
 */
export async function queryTokenListByAddress(
  flowServ: FlowService,
  address: string,
  reviewer?: string
): Promise<TokenQueryResult> {
  const ret = await flowServ.executeScript(
    scQueryTokenListByAddress,
    (arg, t) => [arg(address, t.Address), arg(reviewer, t.Optional(t.Address))],
    { total: "0", list: [] }
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
  flowServ: FlowService,
  page: number,
  limit: number,
  reviewer?: string,
  filter?: FilterType
): Promise<TokenQueryResult> {
  const ret = await flowServ.executeScript(
    scQueryTokenList,
    (arg, t) => [
      arg(page.toFixed(0), t.Int),
      arg(limit.toFixed(0), t.Int),
      arg(reviewer, t.Optional(t.Address)),
      arg(filter?.toString(), t.Optional(t.UInt8)),
    ],
    { total: "0", list: [] }
  );
  return {
    total: parseInt(ret.total),
    list: ret.list.map(parseTokenView),
  };
}
