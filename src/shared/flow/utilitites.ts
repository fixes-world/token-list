import type { FlowService } from "@shared/flow/flow.service";
import type { InjectionKey } from "vue";

/**
 * Injection key for FlowService
 */
export const FlowSrvKey = Symbol("flowSrv") as InjectionKey<FlowService>;

/**
 * Check if the address is a valid Flow address
 */
export function isValidFlowAddress(addr: string) {
  const regExp = /0x[a-fA-F0-9]{16}/gi;
  return regExp.test(addr);
}
