<script setup lang="ts">
import {
  inject, ref, computed, watch, onMounted, reactive, toRaw,
} from 'vue';
import { FlowSrvKey, isValidFlowAddress } from '@shared/flow/utilitites';
import { useGlobalAccount } from '@components/shared';
import { reviewerPublishMaintainer } from '@shared/flow/action/transactions';

import EnsureConnected from '@components/flow/EnsureConnected.vue';
import FlowSubmitTrxWidget from '@components/flow/FlowSubmitTrxWidget.vue';
import type { ReviewerInfo } from '@shared/flow/entities';

const props = withDefaults(defineProps<{
  reviewerInfo: ReviewerInfo | null,
  address?: string,
}>(), {
  reviewerInfo: null,
});

const emits = defineEmits<{
  (e: 'success'): void,
  (e: 'cancel'): void,
  (e: 'error', msg: string): void
}>();

const flowSrv = inject(FlowSrvKey)
const acctName = useGlobalAccount()

// Reactive Data

const isChanged = computed(() => {
  return !!props.address
})
const isValidData = computed(() => isChanged.value && props.reviewerInfo?.address == acctName.value && isValidFlowAddress(props.address!))

const disableReason = computed(() => {
  if (!isChanged.value) {
    return "No changes"
  }
  if (!acctName.value) {
    return "No active account"
  }
  if (!props.reviewerInfo) {
    return "No reviewer info"
  }
  if (props.reviewerInfo.address !== acctName.value) {
    return "You are not the reviewer"
  }
  if (!isValidFlowAddress(props.address!)) {
    return "Maintainer is not a valid Flow address"
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
  }
  if (errStr !== undefined) {
    emits('error', errStr)
    throw new Error(errStr)
  }

  return await reviewerPublishMaintainer(flowSrv!, props.address!)
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
  <EnsureConnected
    :w-full="true"
    size="small"
  >
    <template #not-connected>
      Connect Wallet
    </template>
    <FlowSubmitTrxWidget
      size="small"
      :without-cancel="true"
      :w-full="true"
      :method="onSubmit"
      :disabled="!isValidData"
      :disabled-reason="disableReason"
      @success="onSuccess"
      @cancel="onCancel"
    >
      <template #icon>
        <span class="i-carbon:add w-5 h-5" />
      </template>
      <span>Add Maintainer</span>
    </FlowSubmitTrxWidget>
  </EnsureConnected>
</template>
