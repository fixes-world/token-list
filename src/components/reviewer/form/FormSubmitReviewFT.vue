<script setup lang="ts">
import { ref, reactive, computed, inject, watch, h, type VNodeChild, type VNode } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import type { TagableItem } from '@shared/flow/entities';
import { EvaluationType } from '@shared/flow/enums';
import { parseReviewData } from '@shared/flow/utilitites'
import { maintainerReviewFT, nftListMaintainerReviewNFT } from '@shared/flow/action/transactions';
import { useGlobalAccount } from '@components/shared'

import FlowSubmitTrxWidget from '@components/flow/FlowSubmitTrxWidget.vue';

const props = withDefaults(defineProps<{
  item: TagableItem,
  rank?: EvaluationType,
  tags: string[],
  isNft?: boolean,
}>(), {
  isNft: false,
});

const emits = defineEmits<{
  (e: 'success'): void,
  (e: 'cancel'): void,
  (e: 'error', msg: string): void
}>();

const acctName = useGlobalAccount()

// Reactive Data

const isChanged = computed(() => {
  const data = parseReviewData(props.item)
  return data.rank !== props.rank || data.tags.sort().join(',') !== props.tags.sort().join(',')
})

const isValidData = computed(() => {
  return !!acctName.value
    && (props.rank !== undefined || props.tags.length > 0)
})

const disableReason = computed(() => {
  if (!isChanged.value) return "No changes"
  if (!acctName.value) return "No account name"
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
    return await nftListMaintainerReviewNFT(props.item.identity, props.tags, props.rank)
  } else {
    return await maintainerReviewFT(props.item.identity, props.tags, props.rank)
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
  <FlowSubmitTrxWidget
    :without-cancel="true"
    :w-full="true"
    :method="onSubmit"
    :disabled="!isValidData || !isChanged"
    :disabled-reason="disableReason"
    @success="onSuccess"
    @cancel="onCancel"
  >
    <template #icon>
      <span class="i-carbon:edit w-5 h-5" />
    </template>
    <span>Update Token Reviews</span>
  </FlowSubmitTrxWidget>
</template>
