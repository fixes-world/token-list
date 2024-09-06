import type {
  CustomizedTokenDto,
  NFTCollectionDisplayDto,
  TokenIdentity,
  TokenPaths,
} from "@shared/flow/entities";
import { getFlowInstance } from "../flow.service.factory";
import type { EvaluationType } from "../enums";
// Transactions - FTs
import txRegisterStandardFT from "@cadence/transactions/register-standard-ft.cdc?raw";
import txUpdateViewResolver from "@cadence/transactions/update-ft-view-resolver.cdc?raw";
import txReviewerInit from "@cadence/transactions/reviewer-init.cdc?raw";
import txReviewerPublishMaintainer from "@cadence/transactions/reviewer-publish-maintainer.cdc?raw";
import txMaintainerClaim from "@cadence/transactions/maintainer-claim.cdc?raw";
import txMaintainerRegisterCustomizedFT from "@cadence/transactions/maintainer-register-customized-ft.cdc?raw";
import txMaintainerUpdateCustomizedFT from "@cadence/transactions/maintainer-update-customized-ft-display.cdc?raw";
import txMaintainerUpdateReviewerMetadata from "@cadence/transactions/maintainer-update-reviewer-metadata.cdc?raw";
import txMaintainerReviewFT from "@cadence/transactions/maintainer-reivew-ft.cdc?raw";
// Transactions - NFTs
import txRegisterStandardNFT from "@cadence/transactions/nftlist/register-standard-nft.cdc?raw";
import txNFTListReviewerInit from "@cadence/transactions/nftlist/reviewer-init.cdc?raw";
import txNFTListReviewerPublishMaintainer from "@cadence/transactions/nftlist/reviewer-publish-maintainer.cdc?raw";
import txNFTListMaintainerClaim from "@cadence/transactions/nftlist/maintainer-claim.cdc?raw";
import txNFTListMaintainerUpdateReviewerMetadata from "@cadence/transactions/nftlist/maintainer-update-reviewer-metadata.cdc?raw";
import txNFTListMaintainerUpdateCustomizedDisplay from "@cadence/transactions/nftlist/maintainer-update-customized-display.cdc?raw";
import txNFTListMaintainerReviewNFT from "@cadence/transactions/nftlist/maintainer-reivew-nft.cdc?raw";

/** ---- FTs Transactions ---- */

/**
 * Register a standard FT
 * @param ft The FT to register
 */
export async function registerStandardFT(ft: TokenIdentity): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(txRegisterStandardFT, (arg, t) => [
    arg(ft.address, t.Address),
    arg(ft.contractName, t.String),
  ]);
}

/**
 * Update the view resolver
 * @param ft The FT to register
 */
export async function updateViewResolver(ft: TokenIdentity): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(txUpdateViewResolver, (arg, t) => [
    arg(ft.address, t.Address),
    arg(ft.contractName, t.String),
  ]);
}

/**
 * Initialize the reviewer
 * @returns The transaction ID
 */
export async function reviewerInit() {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(txReviewerInit, (_arg, _t) => []);
}

/**
 * Publish a maintainer
 */
export async function reviewerPublishMaintainer(
  maintainer: string,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(
    txReviewerPublishMaintainer,
    (arg, t) => [arg(maintainer, t.Address)],
  );
}

/**
 * Claim maintainer by reviewer address
 * @param reviewer The reviewer address
 */
export async function maintainerClaim(reviewer: string): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(txMaintainerClaim, (arg, t) => [
    arg(reviewer, t.Address),
  ]);
}

/**
 * Register a customized FT
 */
export async function maintainerRegisterCustomizedFT(
  ft: TokenIdentity,
  paths: TokenPaths,
  display: CustomizedTokenDto,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(
    txMaintainerRegisterCustomizedFT,
    (arg, t) => [
      arg(ft.address, t.Address),
      arg(ft.contractName, t.String),
      arg(paths.vault.slice("/storage/".length), t.String),
      arg(paths.receiver.slice("/public/".length), t.String),
      arg(paths.balance.slice("/public/".length), t.String),
      arg(paths.provider ?? ft.contractName + "_provider", t.String),
      arg(display.name, t.String),
      arg(display.symbol, t.String),
      arg(display.description ?? null, t.Optional(t.String)),
      arg(display.externalURL ?? null, t.Optional(t.String)),
      arg(display.logo ?? null, t.Optional(t.String)),
      arg(display.social, t.Dictionary({ key: t.String, value: t.String })),
    ],
  );
}

export async function maintainerUpdateCustomizedFT(
  ft: TokenIdentity,
  display: CustomizedTokenDto,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(
    txMaintainerUpdateCustomizedFT,
    (arg, t) => [
      arg(ft.address, t.Address),
      arg(ft.contractName, t.String),
      arg(display.name, t.Optional(t.String)),
      arg(display.symbol, t.Optional(t.String)),
      arg(display.description ?? null, t.Optional(t.String)),
      arg(display.externalURL ?? null, t.Optional(t.String)),
      arg(display.logo ?? null, t.Optional(t.String)),
      arg(display.social, t.Dictionary({ key: t.String, value: t.String })),
    ],
  );
}

export async function maintainerUpdateReviwerMetadata(
  name?: string,
  url?: string,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(
    txMaintainerUpdateReviewerMetadata,
    (arg, t) => [
      arg(name ?? null, t.Optional(t.String)),
      arg(url ?? null, t.Optional(t.String)),
    ],
  );
}

export async function maintainerReviewFT(
  ft: TokenIdentity,
  tags: string[],
  rank?: EvaluationType,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(txMaintainerReviewFT, (arg, t) => [
    arg(ft.address, t.Address),
    arg(ft.contractName, t.String),
    arg(
      typeof rank !== "undefined" ? rank.toFixed(0) : null,
      t.Optional(t.UInt8),
    ),
    arg(tags, t.Array(t.String)),
  ]);
}

/** ---- NFTs Transactions ---- */

export async function registerStandardNFT(
  token: TokenIdentity,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(txRegisterStandardNFT, (arg, t) => [
    arg(token.address, t.Address),
    arg(token.contractName, t.String),
  ]);
}

export async function nftListReviewerInit(): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(txNFTListReviewerInit, (_arg, _t) => []);
}

export async function nftListReviewerPublishMaintainer(
  maintainer: string,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(
    txNFTListReviewerPublishMaintainer,
    (arg, t) => [arg(maintainer, t.Address)],
  );
}

export async function nftListMaintainerClaim(
  reviewer: string,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(txNFTListMaintainerClaim, (arg, t) => [
    arg(reviewer, t.Address),
  ]);
}

export async function nftListMaintainerUpdateReviewerMetadata(
  name?: string,
  url?: string,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(
    txNFTListMaintainerUpdateReviewerMetadata,
    (arg, t) => [
      arg(name ?? null, t.Optional(t.String)),
      arg(url ?? null, t.Optional(t.String)),
    ],
  );
}

export async function nftListMaintainerUpdateCustomizedDisplay(
  token: TokenIdentity,
  display: NFTCollectionDisplayDto,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(
    txNFTListMaintainerUpdateCustomizedDisplay,
    (arg, t) => [
      arg(token.address, t.Address),
      arg(token.contractName, t.String),
      arg(display.name, t.String),
      arg(display.description ?? null, t.Optional(t.String)),
      arg(display.externalURL ?? null, t.Optional(t.String)),
      arg(display.squareImage ?? null, t.Optional(t.String)),
      arg(display.bannerImage ?? null, t.Optional(t.String)),
      arg(display.social, t.Dictionary({ key: t.String, value: t.String })),
    ],
  );
}

export async function nftListMaintainerReviewNFT(
  token: TokenIdentity,
  tags: string[],
  rank?: EvaluationType,
): Promise<string> {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(
    txNFTListMaintainerReviewNFT,
    (arg, t) => [
      arg(token.address, t.Address),
      arg(token.contractName, t.String),
      arg(
        typeof rank !== "undefined" ? rank.toFixed(0) : null,
        t.Optional(t.UInt8),
      ),
      arg(tags, t.Array(t.String)),
    ],
  );
}
