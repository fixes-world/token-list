<script setup lang="ts">
import {
  inject, ref, computed, watch, onMounted, reactive, toRaw,
} from 'vue';
import { registerStandardAsset } from '@shared/flow/action/transactions';
import type { NFTStatus } from '@shared/flow/entities';
import { useGlobalAccount } from '@components/shared';

import EnsureConnected from '@components/flow/EnsureConnected.vue';
import FlowSubmitTrxWidget from '@components/flow/FlowSubmitTrxWidget.vue';

const props = withDefaults(defineProps<{
  token: NFTStatus
}>(), {
  // No default value
});

const emits = defineEmits<{
  (e: 'success'): void,
  (e: 'cancel'): void,
  (e: 'error', msg: string): void
}>();

const acctName = useGlobalAccount()

// Reactive Data

const disableReason = computed(() => {
  if (!acctName.value) {
    return "No account name"
  }
  if (props.token.isRegistered) {
    return "Token Already Registered"
  }
  if (!props.token.isWithDisplay) {
    return "No NFTCollectionData or NFTCollectionDisplay view"
  }
  return undefined
})

const isDisabled = computed(() => {
  return props.token.isRegistered || !props.token.isWithDisplay
})

// Handlers and Functions

async function onSubmit(): Promise<string> {
  let errStr: string | undefined = undefined
  if (!acctName.value) {
    errStr = "No account name"
  }
  if (errStr !== undefined) {
    emits('error', errStr)
    throw new Error(errStr)
  }
  return await registerStandardAsset(props.token)
}

async function onSuccess() {
  emits('success')
}

async function onCancel() {
  emits('cancel')
}

// Watchers and Lifecycle

</script>

<template>
  <EnsureConnected :w-full="true">
    <template #not-connected>
      Connect Wallet
    </template>
    <FlowSubmitTrxWidget
      :without-cancel="true"
      :w-full="true"
      :method="onSubmit"
      :disabled="isDisabled"
      :disabled-reason="disableReason"
      @success="onSuccess"
      @cancel="onCancel"
    >
      <template #icon>
        <span class="i-carbon:list w-5 h-5" />
      </template>
      Register to List
    </FlowSubmitTrxWidget>
  </EnsureConnected>
</template>
