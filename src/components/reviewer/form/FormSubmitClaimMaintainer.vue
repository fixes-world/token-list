<script setup lang="ts">
import {
  inject, ref, computed, watch, onMounted, reactive, toRaw,
} from 'vue';
import { FlowSrvKey } from '@shared/flow/utilitites';
import { maintainerClaim } from '@shared/flow/action/transactions';
import type { TokenStatus } from '@shared/flow/entities';
import { useGlobalAccount } from '@components/shared';

import EnsureConnected from '@components/flow/EnsureConnected.vue';
import FlowSubmitTrxWidget from '@components/flow/FlowSubmitTrxWidget.vue';

const props = withDefaults(defineProps<{
  reviewer?: string
}>(), {
  // No default value
});

const emits = defineEmits<{
  (e: 'success'): void,
  (e: 'cancel'): void,
  (e: 'error', msg: string): void
}>();

const flowSrv = inject(FlowSrvKey)
const acctName = useGlobalAccount()

// Reactive Data

const isValidData = computed(() => !!props.reviewer && props.reviewer !== acctName.value)

const disableReason = computed(() => {
  if (!props.reviewer) {
    return "You have not been set as a Maintainer by anyone yet"
  }
  if (!acctName.value) {
    return "No account name"
  }
  if (!isValidData.value) {
    return "The reviewer is you"
  }
  return undefined
})

// Handlers and Functions

async function onSubmit(): Promise<string> {
  let errStr: string | undefined = undefined
  if (flowSrv === undefined) {
    errStr = "Flow Service not available"
  } else if (!acctName.value) {
    errStr = "No account name"
  } else if (!props.reviewer) {
    errStr = "You have not been set as a Maintainer by anyone yet"
  } else if (!isValidData.value) {
    errStr = "The reviewer is you"
  }
  if (errStr !== undefined) {
    emits('error', errStr)
    throw new Error(errStr)
  }

  return await maintainerClaim(flowSrv!, props.reviewer!)
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
      :disabled="!isValidData"
      :disabled-reason="disableReason"
      @success="onSuccess"
      @cancel="onCancel"
    >
      <template #icon>
        <span class="i-carbon:person w-5 h-5" />
      </template>
      <span>Claim your <strong>Maintainer</strong> Role</span>
    </FlowSubmitTrxWidget>
  </EnsureConnected>
</template>
