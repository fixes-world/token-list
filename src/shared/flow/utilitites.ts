import type { FlowService } from "@shared/flow/flow.service";
import type { InjectionKey } from "vue";

/**
 * Injection key for FlowService
 */
export const FlowSrvKey = Symbol("flowSrv") as InjectionKey<FlowService>;
