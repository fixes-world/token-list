<script setup lang="ts">
import {
  inject, ref, computed, watch, onMounted, reactive, toRaw,
} from 'vue';
import { registerEVMAsset } from '@shared/flow/action/transactions';
import type { EVMAssetStatus } from '@shared/flow/entities';
import { useGlobalAccount } from '@components/shared';

import EnsureConnected from '@components/flow/EnsureConnected.vue';
import FlowSubmitTrxWidget from '@components/flow/FlowSubmitTrxWidget.vue';

const props = withDefaults(defineProps<{
  token: EVMAssetStatus,
}>(), {
});

const emits = defineEmits<{
  (e: 'success'): void,
  (e: 'cancel'): void,
  (e: 'error', msg: string): void
}>();

const acctName = useGlobalAccount()

// Reactive Data

const isDisabled = computed(() => {
  return props.token.isRegistered
})

const disableReason = computed(() => {
  if (!acctName.value) {
    return "No account name"
  }
  if (props.token.isRegistered) {
    return "The asset is already registered"
  }
  return undefined
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
  return await registerEVMAsset(props.token.evmAddress)
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
      <span v-if="!token.isRegistered">Register to List</span>
    </FlowSubmitTrxWidget>
  </EnsureConnected>
</template>
