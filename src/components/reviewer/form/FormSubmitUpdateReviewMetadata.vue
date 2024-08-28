<script setup lang="ts">
import {
  inject, ref, computed, watch, onMounted, reactive, toRaw,
} from 'vue';
import { FlowSrvKey } from '@shared/flow/utilitites';
import { maintainerUpdateReviwerMetadata, nftListMaintainerUpdateReviewerMetadata } from '@shared/flow/action/transactions';
import { useGlobalAccount } from '@components/shared';

import EnsureConnected from '@components/flow/EnsureConnected.vue';
import FlowSubmitTrxWidget from '@components/flow/FlowSubmitTrxWidget.vue';
import type { ReviewerInfo } from '@shared/flow/entities';

const props = withDefaults(defineProps<{
  isNft?: boolean
  reviewerInfo: ReviewerInfo | null,
  name?: string,
  url?: string,
}>(), {
  isNft: false,
  reviewerInfo: null,
});

const emits = defineEmits<{
  (e: 'success'): void,
  (e: 'cancel'): void,
  (e: 'error', msg: string): void
}>();

const acctName = useGlobalAccount()

// Reactive Data

const isChanged = computed(() => {
  return (!!props.name && props.reviewerInfo?.name !== props.name) ||
    (props.url && props.reviewerInfo?.url !== props.url)
})
const isValidData = computed(() => isChanged.value && !!props.name && !!props.url)

const disableReason = computed(() => {
  if (!isChanged.value) {
    return "No changes"
  }
  if (!acctName.value) {
    return "No active account"
  }
  if (!props.name) {
    return "Name is required"
  }
  if (!props.url) {
    return "Website is required"
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

  if (props.isNft) {
    return await nftListMaintainerUpdateReviewerMetadata(props.name!, props.url!)
  } else {
    return await maintainerUpdateReviwerMetadata(props.name!, props.url!)
  }
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
        <span class="i-carbon:edit w-5 h-5" />
      </template>
      <span>Update Reviewer Metadata</span>
    </FlowSubmitTrxWidget>
  </EnsureConnected>
</template>
