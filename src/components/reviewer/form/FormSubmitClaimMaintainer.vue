<script setup lang="ts">
import {
  inject, ref, computed, watch, onMounted, reactive, toRaw,
} from 'vue';
import { maintainerClaim, nftListMaintainerClaim } from '@shared/flow/action/transactions';
import { useGlobalAccount } from '@components/shared';

import EnsureConnected from '@components/flow/EnsureConnected.vue';
import FlowSubmitTrxWidget from '@components/flow/FlowSubmitTrxWidget.vue';

const props = withDefaults(defineProps<{
  isNft?: boolean,
  reviewer?: string
}>(), {
  isNft: false,
  reviewer: undefined
});

const emits = defineEmits<{
  (e: 'success'): void,
  (e: 'cancel'): void,
  (e: 'error', msg: string): void
}>();

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
  if (!acctName.value) {
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
  if (props.isNft) {
    return await nftListMaintainerClaim(props.reviewer!)
  } else {
    return await maintainerClaim(props.reviewer!)
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
      <span>Claim your {{ props.isNft ? "NFTList" : "TokenList" }} <strong>Maintainer</strong> Role</span>
    </FlowSubmitTrxWidget>
  </EnsureConnected>
</template>
