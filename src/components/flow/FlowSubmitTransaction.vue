<script setup lang="ts">
import { ref, computed } from 'vue';
import { NButton, useDialog } from 'naive-ui';
import type { TransactionStatus } from "@onflow/typedefs";
import { useNetworkCorrect } from "@components/shared";
import { ClientNotificationError } from '@shared/exception.client';

import FlowWaitTransaction from './FlowWaitTransaction.vue';

const isNetworkCorrect = useNetworkCorrect();

const props = withDefaults(
  defineProps<{
    method: (e: MouseEvent) => Promise<string | null>;
    type?: 'default' | 'tertiary' | 'primary' | 'success' | 'info' | 'warning' | 'error',
    size?: 'tiny' | 'small' | 'medium' | 'large',
    content?: string;
    action?: string;
    disabled?: boolean;
    hideSendingError?: boolean;
    hideButton?: boolean;
    hideTrx?: boolean;
  }>(),
  {
    content: "Submit",
    type: 'primary',
    size: 'large',
    action: '',
    disabled: false,
    hideSendingError: true,
    hideButton: false,
    hideTrx: false,
  }
);

const emit = defineEmits<{
  (e: 'sent', txid: string | null): void;
  (e: "sealed", tx: TransactionStatus): void;
  (e: 'success'): void;
  (e: "error", message: string | null): void;
  (e: "reset"): void;
}>();

const dialog = useDialog();
const txid = ref<string | null>(null);
const isLoading = ref(false);
const errorMessage = ref<string | null>(null);
const isSealed = ref<boolean | undefined>(undefined);

const isBusy = computed(() => isLoading.value || isSealed.value === false);
const isDisabled = computed(() => !isNetworkCorrect.value || isBusy.value);

async function startTransaction(e: MouseEvent) {
  e.preventDefault();
  if (!isNetworkCorrect.value || isLoading.value) return;

  isLoading.value = true;
  errorMessage.value = null;
  isSealed.value = false;
  try {
    txid.value = await props.method(e);
    emit("sent", txid.value);
  } catch (err: any) {
    isSealed.value = true;
    console.error(err);
    // Popup error message for client notification error
    if (err instanceof ClientNotificationError) {
      dialog.error({
        title: "Transaction Error",
        content: err.message,
      })
    }
    // Display error message
    if (!props.hideSendingError) {
      const msg = String(err.reason ?? err.message ?? "rejected");
      errorMessage.value = msg.length > 60 ? msg.slice(0, 60) + "..." : msg;
    }
    emit("error", errorMessage.value);
  }
  isLoading.value = false;
}

function onSealed(trxId: string, tx: TransactionStatus) {
  isSealed.value = true;
  if (!tx.errorMessage) {
    emit("success")
  }
  emit("sealed", tx);
  // avoid no closed
  setTimeout(() => {
    if (txid.value) {
      resetComponent()
    }
  }, 5000);
}

function onError(msg: string) {
  errorMessage.value = msg
  emit("error", msg);
}

function resetComponent() {
  emit("reset")
  txid.value = null;
  errorMessage.value = null;
  isSealed.value = undefined;
}

// expose members
defineExpose({
  resetComponent: ref(resetComponent),
  startTransaction: ref(startTransaction),
  isLoading,
  isSealed
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
    <template v-else-if="!hideButton && (!txid || !isSealed)">
      <NButton
        role="button"
        strong
        round
        :size="size"
        style="width: 100%;"
        :type="type"
        :aria-busy="isBusy"
        :loading="isBusy"
        :disabled="isDisabled"
        :aria-disabled="isDisabled"
        @click.stop.prevent="startTransaction"
      >
        <template #icon>
          <slot name="icon" />
        </template>
        <slot>
          {{ content }}
        </slot>
      </NButton>
      <p
        v-if="errorMessage"
        class="w-full max-h-20 overflow-y-scroll px-4 mb-0 text-xs"
      >
        {{ errorMessage }}
      </p>
    </template>
    <slot
      v-if="!hideButton && (txid && isSealed)"
      name="next"
    >
      <NButton
        role="button"
        strong
        round
        :size="size"
        style="width: 100%;"
        :type="type"
        ghost
        @click.stop.prevent="resetComponent"
      >
        Close
      </NButton>
    </slot>
    <Teleport to="body">
      <FlowWaitTransaction
        v-if="txid"
        :hidden="hideTrx"
        :txid="txid"
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
