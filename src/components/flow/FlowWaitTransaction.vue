<script setup lang="ts">
import type { TransactionStatus } from "@onflow/typedefs";
import appInfo from "@shared/config/info";
import { getFlowInstance } from "@shared/flow/flow.service.factory";
import { breakpointsTailwind, useBreakpoints } from "@vueuse/core";
import { NProgress } from "naive-ui";
import { computed, onBeforeUnmount, onMounted, ref, watch } from "vue";

const props = withDefaults(
  defineProps<{
    txid?: string;
    hidden?: boolean;
  }>(),
  {
    txid: undefined,
    hidden: false,
  },
);

const emit = defineEmits<{
  (e: "updated", tx: TransactionStatus): void;
  (e: "finalized", txid: string, tx: TransactionStatus): void;
  (e: "sealed", txid: string, tx: TransactionStatus): void;
  (e: "error", message: string): void;
  (e: "close"): void;
}>();

const breakpoints = useBreakpoints(breakpointsTailwind);
const isOnDesktop = breakpoints.greaterOrEqual("lg");

const txStatus = ref<TransactionStatus | null>(null);

const txStatusString = computed(() => {
  const STATUS_MAP: { [key: number]: string } = {
    0: "SENT",
    1: "PENDING",
    2: "FINALIZED",
    3: "EXECUTED",
    4: "SEALED",
    5: "EXPIRED",
  };
  if (txStatus.value) {
    return txStatus.value?.statusString ?? STATUS_MAP[txStatus.value?.status || 0];
  }
  return props.txid ? "SENT" : "INITIALIZING";
});

const progress = computed(() => {
  const status = txStatus.value?.status ?? 0;
  switch (status) {
    case 0:
      return 15;
    case 1:
    case 2:
    case 3:
    case 4:
      return Math.min(100, status * 25);
    case 5:
      return undefined;
  }
});

const txidDisplay = computed(() => {
  if (props.txid) {
    const str = props.txid ?? "Unknown";
    return `${str.slice(0, 6)}...${str.slice(str.length - 6)}`;
  }
  return "Please wait...";
});

let unsub: any;

async function startSubscribe() {
  if (!props.txid) return;
  if (unsub) return;

  try {
    console.info(
      `%cTX[${props.txid}]: ${getTxURL(props.txid)}`,
      "color:purple;font-weight:bold;font-family:monospace;",
    );
    const flowSrv = await getFlowInstance();
    unsub = await flowSrv.watchTransaction(
      props.txid,
      (status: TransactionStatus) => {
        if (typeof status.status === "number") {
          txStatus.value = status;
          emit("updated", status);
        }
      },
      (txId: string, status: TransactionStatus) => {
        emit("finalized", txId, status);
      },
      (txId: string, status: TransactionStatus, errorMsg?: string) => {
        emit("sealed", txId, status);
      },
      (errorMsg?: string) => {
        if (errorMsg && errorMsg.length > 0) {
          emit("error", errorMsg);
        }
      },
    );
  } catch (err: any) {
    console.error(`TX[${props.txid}]: ${getTxURL(props.txid)}`, err);
    emit("error", err.message);
  }
}

function stopSubscribe() {
  if (typeof unsub === "function") {
    unsub();
  }
}

function getTxURL(txId: string) {
  const host =
    appInfo.network === "testnet"
      ? "https://testnet.flowscan.io/tx/"
      : "https://www.flowscan.io/tx/";
  return host + txId;
}

watch(
  () => props.txid,
  (txid) => {
    if (txid) {
      startSubscribe();
    }
  },
  { immediate: true },
);

onBeforeUnmount(stopSubscribe);
</script>

<template>
  <div
    v-if="!hidden"
    :class="['fixed z-100 right-0', isOnDesktop ? 'bottom-0' : 'bottom-16',
      'rounded-xl p-2 w-fit max-w-screen md:max-w-[80%] lg:max-w-[50%]',
      'flex flex-col items-center justify-center',
      'bg-[var(--bg-color-dark)]'
    ]"
  >
    <div :class="[
  'flex flex-col gap-2',
  'relative w-full px-3 py-2 rounded-lg',
  'border-2 border-solid border-[var(--primary-color)]',
  'text-center bg-[var(--bg-color)]',
]">
      <slot></slot>
      <div :class="[
  'flex items-center gap-2 pr-6',
  'font-semibold text-lg text-[var(--base-color)]'
]">
        <span class="">{{ txStatusString }}</span>
        <a
          :href="txid ? getTxURL(txid) : undefined"
          target="_blank"
          class="highlight"
        >
          {{ txidDisplay }}
        </a>
      </div>
      <NProgress
        type="line"
        :percentage="progress"
        indicator-placement="inside"
        status="success"
        processing
      />
      <div
        v-if="progress && progress >= 100"
        class="i-carbon:misuse w-5 h-5 absolute top-3 right-3 cursor-pointer"
        @click="emit('close')"
      />
    </div>
    <slot name="append"></slot>
  </div>
</template>
