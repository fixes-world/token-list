<script setup lang="ts">
import { computed, onUnmounted, ref } from 'vue';
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import { NSkeleton, NButton, NDialogProvider } from 'naive-ui';
import { useSendingTransaction } from '@components/shared';

import FlowSubmitTransaction from './FlowSubmitTransaction.vue';

const props = withDefaults(defineProps<{
  method: (e: MouseEvent) => Promise<string | null>;
  type?: 'default' | 'tertiary' | 'primary' | 'success' | 'info' | 'warning' | 'error',
  size?: 'tiny' | 'small' | 'medium' | 'large',
  content?: string;
  action?: string;
  disabled?: boolean;
  disabledReason?: string;
  withoutCancel?: boolean;
  wFull?: boolean;
}>(), {
  disabled: false,
  disabledReason: undefined,
  withoutCancel: false,
  wFull: false,
});

const emits = defineEmits<{
  (e: 'sent', txid: string | null): void
  (e: 'success'): void,
  (e: 'error'): void,
  (e: 'reset'): void,
  (e: 'cancel'): void,
}>();

const breakpoints = useBreakpoints(breakpointsTailwind)
const isNotMobile = breakpoints.greaterOrEqual('md')

const isSending = useSendingTransaction();

// Reactive Data

// Handlers Functions

function onTrxSent(txid: string | null) {
  isSending.value = true
  emits('sent', txid)
}

function onCancel() {
  isSending.value = false
  emits('cancel')
}

function onTrxSuccess() {
  isSending.value = false
  emits('success')
}

function onTrxError() {
  isSending.value = false
  emits('error')
}

onUnmounted(() => {
  if (isSending.value) {
    isSending.value = false
  }
})

</script>

<template>
<NDialogProvider>
  <div :class="['flex flex-col-reverse lg:flex-row items-center gap-2', { 'w-full': wFull }]">
    <div class="w-full lg:w-auto flex-auto flex items-center gap-2">
      <div
        v-if="!withoutCancel"
        class="flex-none w-16 lg:w-32"
      >
        <NButton
          style="width: 100%;"
          :size="isNotMobile ? 'large' : 'small'"
          strong round ghost
          :disabled="isSending"
          @click.stop.prevent="onCancel">
          <span class="i-carbon:close-large w-5 h-5 inline-block lg:hidden" />
          <span class="hidden lg:inline-block">Cancel</span>
        </NButton>
      </div>
      <FlowSubmitTransaction
        class="flex-auto"
        :action="action"
        :size="isNotMobile ? size : 'small'"
        :type="type"
        :disabled="disabled || isSending"
        :method="method"
        @sent="onTrxSent"
        @success="onTrxSuccess"
        @error="onTrxError"
        @reset="emits('reset')"
      >
        <template #icon>
          <slot name="icon" />
        </template>
        <template #disabled>
          <slot name="disabled">
            {{
              disabled
              ? disabledReason ?? 'Please Wait'
              : isSending
                ? "Transaction Sending"
                : 'Balance Not Enough'
            }}
          </slot>
        </template>
        <template #default>
          <slot>
            {{ content }}
          </slot>
        </template>
      </FlowSubmitTransaction>
    </div>
  </div>
</NDialogProvider>
</template>
