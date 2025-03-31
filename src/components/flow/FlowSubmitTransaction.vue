<script setup lang="ts">
import { transactionExecutedKey, useNetworkCorrect } from "@components/shared";
import type { TransactionStatus } from "@onflow/typedefs";
import Exception from "@shared/exception";
import { ClientNotificationError } from "@shared/exception.client";
import { NButton, useDialog, useMessage } from "naive-ui";
import { computed, onUnmounted, ref } from "vue";

import { useEventBus } from "@vueuse/core";
import FlowWaitTransaction from "./FlowWaitTransaction.vue";

const props = withDefaults(
  defineProps<{
    method: (e: MouseEvent) => Promise<string | null>;
    type?: "default" | "tertiary" | "primary" | "success" | "info" | "warning" | "error";
    size?: "tiny" | "small" | "medium" | "large";
    content?: string;
    action?: string;
    disabled?: boolean;
    hideSendingError?: boolean;
    hideButton?: boolean;
    hideTrx?: boolean;
  }>(),
  {
    content: "Submit",
    type: "primary",
    size: "large",
    action: "",
    disabled: false,
    hideSendingError: true,
    hideButton: false,
    hideTrx: false,
  },
);

const emit = defineEmits<{
  (e: "sent", txid: string | null): void;
  (e: "finalized", tx: TransactionStatus): void;
  (e: "sealed", tx: TransactionStatus): void;
  (e: "success"): void;
  (e: "error", message: string | null): void;
  (e: "reset"): void;
}>();

const isNetworkCorrect = useNetworkCorrect();
const dialog = useDialog();
const uiMessage = useMessage();
const txExecutedBus = useEventBus(transactionExecutedKey);

const txid = ref<string | null>(null);
const isLoading = ref(false);
const errorMessage = ref<string | null>(null);
const isFinalized = ref<boolean | undefined>(undefined);
const isSealed = ref<boolean | undefined>(undefined);

const isBusy = computed(() => isLoading.value || isFinalized.value === false);
const isSubmitTxDisabled = computed(() => !isNetworkCorrect.value || isBusy.value);
const disabledReason = computed(() => (!isNetworkCorrect.value ? "Network Incorrect" : undefined));

async function startTransaction(e: MouseEvent) {
  e.preventDefault();
  if (!isNetworkCorrect.value || isLoading.value) return;

  isLoading.value = true;
  errorMessage.value = null;
  isFinalized.value = false;
  isSealed.value = false;
  try {
    txid.value = await props.method(e);
    emit("sent", txid.value);
  } catch (err: any) {
    isFinalized.value = true;
    isSealed.value = true;
    console.error(err);
    // Popup error message for client notification error
    if (err instanceof ClientNotificationError || err instanceof Exception) {
      dialog.error({
        title: "Transaction Error",
        content: err.message,
      });
    }
    // Display error message
    if (!props.hideSendingError) {
      const msg = String(err.reason ?? err.message ?? "rejected");
      errorMessage.value = msg.length > 60 ? `${msg.slice(0, 60)}...` : msg;
    }
    emit("error", errorMessage.value);
  }
  isLoading.value = false;
}

function onFinalized(txId: string, tx: TransactionStatus) {
  emit("finalized", tx);
  if (!tx.errorMessage) {
    emit("success");
  }
  txExecutedBus.emit(txId);
  isFinalized.value = true;
}

function onSealed(trxId: string, tx: TransactionStatus) {
  emit("sealed", tx);
  isSealed.value = true;

  // avoid no closed
  setTimeout(() => {
    if (txid.value) {
      resetComponent();
    }
  }, 5000);
}

function onError(msg: string) {
  errorMessage.value = msg;
  uiMessage.error(`Transaction Error: ${msg.slice(0, 150)}`);
  emit("error", msg);
}

function resetComponent() {
  emit("reset");

  cleanUp();
}

function cleanUp() {
  txid.value = null;
  errorMessage.value = null;
  isFinalized.value = undefined;
  isSealed.value = undefined;
}

onUnmounted(() => {
  cleanUp();
});

// expose members
defineExpose({
  resetComponent: ref(resetComponent),
  startTransaction: ref(startTransaction),
  isLoading,
});
</script>

<template>
  <div class="flex flex-col gap-2 rounded-xl">
    <NButton
      v-if="disabled && !txid"
      role="button"
      strong
      round
      :size="size"
      style="width: 100%;"
      disabled
    >
      <slot name="disabled">
        Disabled
      </slot>
    </NButton>
    <template v-else-if="!hideButton && (!txid || !isFinalized)">
      <NButton
        role="button"
        strong
        round
        :size="size"
        style="width: 100%;"
        :type="type"
        :aria-busy="isBusy"
        :loading="isBusy"
        :disabled="isSubmitTxDisabled"
        :aria-disabled="isSubmitTxDisabled"
        @click.stop.prevent="startTransaction"
      >
        <template #icon>
          <slot name="icon" />
        </template>
        <template v-if="isSubmitTxDisabled && disabledReason">
          {{ disabledReason }}
        </template>
        <slot v-else>
          {{ content }}
        </slot>
      </NButton>
    </template>
    <slot
      v-if="!hideButton && (txid && isFinalized)"
      name="next"
    >
      <NButton
        role="button"
        strong
        round
        :size="size"
        style="width: 100%;"
        :type="!isSealed ? 'warning' : type"
        :disabled="!isSealed"
        ghost
        @click.stop.prevent="resetComponent"
      >
        {{ !isSealed ? "Sealing..." : "Close" }}
      </NButton>
    </slot>
    <Teleport to="body">
      <FlowWaitTransaction
        v-if="txid"
        :hidden="hideTrx"
        :txid="txid ?? undefined"
        @finalized="onFinalized"
        @sealed="onSealed"
        @error="onError"
        @close="resetComponent"
      >
        <template v-if="action != ''">
          <span class="mb-0 font-medium text-sm">{{ action }}</span>
        </template>
        <template #append>
          <pre
            v-if="errorMessage"
            class="w-full max-h-20 overflow-scroll px-4 mb-0 text-xs text-[var(--error-color)]"
          >{{ errorMessage }}</pre>
        </template>
      </FlowWaitTransaction>
    </Teleport>
  </div>
</template>
