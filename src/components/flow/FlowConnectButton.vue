<script setup lang="ts">
import { inject, ref } from 'vue'
import { FlowSrvKey } from '@shared/flow/utilitites';
import {
  useCurrentFlowUser,
} from '@components/shared'
import { NButton } from "naive-ui"
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

const flowSrv = inject(FlowSrvKey);
const current = useCurrentFlowUser();

const isInitializingWalletConnect = ref(false)

async function login() {
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

function logout() {
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
