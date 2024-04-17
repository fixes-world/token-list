import type { FlowService } from "@shared/flow/flow.service";
import type { InjectionKey } from "vue";
import type { ExportedTokenInfo, StandardTokenView } from "./entities";

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
    address: ft.identity.address,
    contractName: ft.identity.contractName,
    path: ft.path,
    symbol: ft.display.display.symbol,
    name: ft.display.display.name,
    description: ft.display?.display?.description ?? "",
    decimals: ft.decimals,
    logoURI: ft.display.display.logos[0].uri,
    tags: ft.tags ?? [],
    extensions,
  };
}
