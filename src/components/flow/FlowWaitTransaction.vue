<script setup lang="ts">
import { ref, computed, inject, onMounted, onBeforeUnmount } from "vue";
import type { TransactionStatus } from "@onflow/typedefs";
import { FlowSrvKey } from "@shared/flow/utilitites";
import { NProgress } from 'naive-ui';

const props = withDefaults(defineProps<{
  txid: string;
  hidden?: boolean;
}>(), {
  hidden: false
});

const emit = defineEmits<{
  (e: "updated", tx: TransactionStatus): void;
  (e: "sealed", txid: string, tx: TransactionStatus): void;
  (e: "error", message: string): void;
  (e: "close"): void;
}>();

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
  return (
    txStatus.value?.statusString ?? STATUS_MAP[txStatus.value?.status || 0]
  );
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
  const str = props.txid;
  return str.slice(0, 6) + "..." + str.slice(str.length - 6);
});

const flowSrv = inject(FlowSrvKey)

let unsub: any;

async function startSubscribe() {
  try {
    console.info(
      `%cTX[${props.txid}]: ${getTxURL(props.txid)}`,
      "color:purple;font-weight:bold;font-family:monospace;"
    );
    unsub = await flowSrv?.watchTransaction(
      props.txid,
      (status: TransactionStatus) => {
        if (typeof status.status === 'number') {
          txStatus.value = status;
          emit("updated", status);
        }
      },
      (txId: string, status: TransactionStatus, errorMsg?: string) => {
        emit("sealed", txId, status);
        if (errorMsg && errorMsg.length > 0) {
          emit("error", errorMsg)
        }
      }
    )
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
  const host = flowSrv?.network === 'testnet'
    ? "https://testnet.flowdiver.io/tx/"
    : "https://www.flowdiver.io/tx/"
  return host + txId;
}

onMounted(startSubscribe);
onBeforeUnmount(stopSubscribe);
</script>

<template>
<div
  v-if="!hidden"
  :class="[
    'fixed z-100 right-0 bottom-0',
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
      <a :href="getTxURL(txid)" target="_blank" class="highlight">
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
