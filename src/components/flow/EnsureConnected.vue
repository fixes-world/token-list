<script setup lang="ts">
import { computed, ref } from 'vue'
import { useEventBus } from '@vueuse/core';
import {
  useIsConnected,
  useNetworkCorrect,
  useCurrentFlowUser,
} from '@components/shared'
import { NTag, NButton } from 'naive-ui'

import FlowConnectButton from './FlowConnectButton.vue'

const props = withDefaults(defineProps<{
  type?: 'default' | 'tertiary' | 'primary' | 'success' | 'info' | 'warning' | 'error',
  size?: 'tiny' | 'small' | 'medium' | 'large',
  wFull?: boolean
  forceConnectFlow?: boolean
}>(), {
  type: 'primary',
  size: 'medium',
  wFull: false,
  forceConnectFlow: false,
})

const currentFlowUser = useCurrentFlowUser();
const isNetworkCorrect = useNetworkCorrect();
const isConnected = useIsConnected()

// Reactive Data


// Handlers and Functions

</script>

<template>
  <div
    v-if="currentFlowUser && !isNetworkCorrect"
    :class="['flex justify-center', { 'w-full': wFull }]"
  >
    <NTag
      type="error"
      size="medium"
      round
    >
      Incorrect Network
    </NTag>
  </div>
  <FlowConnectButton
    v-else-if="!isConnected"
    :type="type"
    :size="size"
    :w-full="wFull"
  >
    <template #icon>
      <span class="i-carbon:wallet w-4 h-4" />
    </template>
    <slot name="not-connected">
      <span class="text-sm">Connect</span>
    </slot>
  </FlowConnectButton>
  <slot v-else-if="isConnected">
    <span class="text-[var(--primary-color)]">Connected</span>
  </slot>
</template>
