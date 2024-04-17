import type {
  CustomizedTokenDto,
  TokenIdentity,
  TokenPaths,
} from "@shared/flow/entities";
import { getFlowInstance } from "../flow.service.factory";
// Transactions
import txRegisterStandardFT from "@cadence/transactions/register-standard-ft.cdc?raw";
import txReviewerInit from "@cadence/transactions/reviewer-init.cdc?raw";
import txReviewerPublishMaintainer from "@cadence/transactions/reviewer-publish-maintainer.cdc?raw";
import txMaintainerClaim from "@cadence/transactions/maintainer-claim.cdc?raw";
import txMaintainerRegisterCustomizedFT from "@cadence/transactions/maintainer-register-customized-ft.cdc?raw";
import txMaintainerUpdateCustomizedFT from "@cadence/transactions/maintainer-update-customized-ft-display.cdc?raw";
import txMaintainerUpdateReviewerMetadata from "@cadence/transactions/maintainer-update-reviewer-metadata.cdc?raw";

/** ---- Transactions ---- */

/**
 * Register a standard FT
 * @param flowSrv The FlowService instance
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
 * Initialize the reviewer
 * @param flowSrv The FlowService instance
 * @returns The transaction ID
 */
export async function reviewerInit() {
  const flowSrv = await getFlowInstance();
  return await flowSrv.sendTransaction(txReviewerInit, (arg, t) => []);
}

/**
 * Publish a maintainer
 * @param flowSrv The FlowService instance
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
 * @param flowSrv The FlowService instance
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
 * @param flowSrv The FlowService instance
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
