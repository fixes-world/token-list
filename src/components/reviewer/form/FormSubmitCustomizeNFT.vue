<script setup lang="ts">
import { ref, reactive, computed, inject, watch, h, type VNodeChild, type VNode } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import type { Media, NFTCollectionDisplayDto, NFTPaths, StandardNFTCollectionView } from '@shared/flow/entities';
import { nftListMaintainerUpdateCustomizedDisplay } from '@shared/flow/action/transactions';
import { useGlobalAccount } from '@components/shared'

import FlowSubmitTrxWidget from '@components/flow/FlowSubmitTrxWidget.vue';

const props = defineProps<{
  nft: StandardNFTCollectionView,
  display?: NFTCollectionDisplayDto
}>()

const emits = defineEmits<{
  (e: 'success'): void,
  (e: 'cancel'): void,
  (e: 'error', msg: string): void
}>();

const acctName = useGlobalAccount()

// Reactive Data

const isChanged = computed(() => {
  let isSocialSame = true
  const socialArr = props.display?.social ?? []
  const oldDict = props.nft.display?.display?.social ?? {}
  for (let social of socialArr) {
    if (oldDict[social.key] !== social.value) {
      isSocialSame = false
      break
    }
  }

  return props.nft.display?.display?.name !== props.display?.name
    || props.nft.display?.display?.description !== props.display?.description
    || props.nft.display?.display?.externalURL !== props.display?.externalURL
    || props.nft.display?.display?.bannerImage?.uri !== props.display?.bannerImage
    || props.nft.display?.display?.squareImage?.uri !== props.display?.squareImage
    || !isSocialSame
})

const isValidData = computed(() => {
  return !!acctName.value
    && !!props.display?.name
    && !!props.display.squareImage
    && !!props.display.bannerImage
})

const disableReason = computed(() => {
  if (!isChanged.value) return "No changes"
  if (!acctName.value) return "No account name"
  if (!props.display?.name) return "No Display Name"
  if (!props.display?.squareImage) return "No Square Logo"
  if (!props.display?.bannerImage) return "No Banner Image"
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

  return await nftListMaintainerUpdateCustomizedDisplay(props.nft.identity, props.display!)
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
      <span class="i-carbon:fetch-upload-cloud w-5 h-5" />
    </template>
    <span>Update Customized Settings</span>
  </FlowSubmitTrxWidget>
</template>
