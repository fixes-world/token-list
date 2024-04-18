<script setup lang="ts">
import { inject, ref } from 'vue'
import { NButton } from "naive-ui"
import { getFlowInstance } from '@shared/flow/flow.service.factory';
import {
  useCurrentFlowUser,
} from '@components/shared'
import FlowLogoWhite from '@assets/flow-white.svg?component';

const props = withDefaults(defineProps<{
  type?: 'default' | 'tertiary' | 'primary' | 'success' | 'info' | 'warning' | 'error',
  size?: 'tiny' | 'small' | 'medium' | 'large',
  wFull?: boolean,
}>(), {
  type: 'primary',
  size: 'medium',
  wFull: false,
})

const current = useCurrentFlowUser();

const isInitializingWalletConnect = ref(false)

async function login() {
  const flowSrv = await getFlowInstance();
  if (!flowSrv?.isWalletConnectInited) {
    isInitializingWalletConnect.value = true
    try {
      await new Promise((resolve, reject) => {
        let promise = flowSrv?.ensureWalletConnect()
        promise?.catch(resolve).catch(reject)
        // resolve after 3 seconds
        setTimeout(() => {
          reject("Timeout: Failed to initialize wallet connect")
        }, 2000)
      })
    } catch (e) {
      console.error(e)
    } finally {
      isInitializingWalletConnect.value = false
    }
  }
  await flowSrv?.authenticate();
}

async function logout() {
  const flowSrv = await getFlowInstance();
  flowSrv?.unauthenticate();
}

defineExpose({
  logout,
})
</script>

<template>
  <NButton
    v-if="!current"
    strong
    round
    :class="[wFull ? '!w-full' : '']"
    :type="type"
    :size="size"
    :loading="isInitializingWalletConnect"
    :disabled="isInitializingWalletConnect"
    @click="login"
  >
    <template #icon>
      <slot name="icon">
        <FlowLogoWhite class="h-5 w-5" />
      </slot>
    </template>
    <slot>
      <span>Connect<span class="hidden lg:inline"> Wallet</span></span>
    </slot>
  </NButton>
</template>
