<script setup lang="ts">
import { ref, reactive, computed, inject, watch, h, type VNodeChild, type VNode } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import type { StandardTokenView, Media, CustomizedTokenDto, SocialKeyPair, TokenPaths } from '@shared/flow/entities';
import { FlowSrvKey } from '@shared/flow/utilitites';
import { maintainerRegisterCustomizedFT, maintainerUpdateCustomizedFT } from '@shared/flow/action/transactions';
import { getFTContractStatus } from '@shared/flow/action/scripts';
import { useGlobalAccount, useSendingTransaction } from '@components/shared'

import FlowSubmitTrxWidget from '@components/flow/FlowSubmitTrxWidget.vue';

const props = defineProps<{
  ft: StandardTokenView,
  paths?: TokenPaths,
  display?: CustomizedTokenDto
}>()

const emits = defineEmits<{
  (e: 'success'): void,
  (e: 'cancel'): void,
  (e: 'error', msg: string): void
}>();

const flowSrv = inject(FlowSrvKey)
const acctName = useGlobalAccount()

// Reactive Data

const vaultPath = computed(() => props.ft.path?.vault || props.paths?.vault)
const receiverPath = computed(() => props.ft.path?.receiver || props.paths?.receiver)
const balancePath = computed(() => props.ft.path?.balance || props.paths?.balance)

const isValidData = computed(() => {
  return !!acctName.value && !!flowSrv
    && !!props.display?.name
    && !!props.display?.symbol
    && !!props.display.logo
    && (!!vaultPath.value && vaultPath.value.startsWith('/storage/'))
    && (!!receiverPath.value && receiverPath.value.startsWith('/public/'))
    && (!!balancePath.value && balancePath.value.startsWith('/public/'))
})

const disableReason = computed(() => {
  if (!acctName.value) return "No account name"
  if (!flowSrv) return "Flow Service not available"
  if (!props.display?.symbol) return "No Token Symbol"
  if (!props.display?.name) return "No Display Name"
  if (!props.display?.logo) return "No Token Logo"
  if (!vaultPath.value) return "No vault path"
  if (!vaultPath.value.startsWith('/storage/')) return "Vault path is not a valid storage path"
  if (!receiverPath.value) return "No receiver path"
  if (!receiverPath.value.startsWith('/public/')) return "Receiver path is not a valid public path"
  if (!balancePath.value) return "No balance path"
  if (!balancePath.value.startsWith('/public/')) return "Balance path is not a valid public path"
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

  if (props.ft.path === undefined && props.paths !== undefined) {
    // Register new Customized FT
    return maintainerRegisterCustomizedFT(
      flowSrv!,
      props.ft.identity,
      props.paths,
      props.display!
    )
  } else {
    // Update the existing Customized FT display
    return maintainerUpdateCustomizedFT(
      flowSrv!,
      props.ft.identity,
      props.display!
    )
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
    :disabled="!isValidData"
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