<script setup lang="ts">
import { computed } from 'vue';
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import { NCard } from 'naive-ui'

const props = withDefaults(defineProps<{
  title?: string,
  size?: 'fit' | 'small' | 'medium' | 'large' | 'xlarge' | 'huge',
  rounded?: 'none' | 'small' | 'medium' | 'large',
  hoverable?: boolean,
}>(), {
  title: '',
  size: 'large',
  rounded: 'small',
  hoverable: false,
});

const breakpoints = useBreakpoints(breakpointsTailwind)
const isOnPCBrowser = breakpoints.greaterOrEqual('lg')

const isLarge = computed(() => props.size === 'large' || props.size === 'xlarge' || props.size === 'huge')

const mappedSize = computed(() => {
  switch (props.size) {
    case 'fit':
      return 'max-w-fit'
    case 'small':
      return 'max-w-xl'
    case 'medium':
      return 'max-w-3xl'
    case 'large':
      return 'max-w-5xl'
    case 'xlarge':
      return 'max-w-7xl'
    case 'huge':
      return 'max-w-full'
  }
})
const mappedRounded = computed(() => {
  switch (props.rounded) {
    case 'none':
      return '!rounded-none'
    case 'small':
      return '!rounded-2'
    case 'medium':
      return '!rounded-4'
    case 'large':
      return '!rounded-8'
  }
})
</script>

<template>
  <NCard
    :hoverable="hoverable"
    :class="[
      isOnPCBrowser ? mappedSize : 'max-w-[calc(100vw-1rem)]',
      isOnPCBrowser ? mappedRounded : '!rounded-2',
    ]"
    :size="!isOnPCBrowser || !isLarge ? 'small' : 'large'"
  >
    <template #header>
      <slot name="header">
        <template v-if="title">{{ title }}</template>
      </slot>
    </template>
    <template #header-extra>
      <slot name="header-extra" />
    </template>
    <slot />
    <template #footer>
      <slot name="footer" />
    </template>
    <template #action>
      <slot name="action" />
    </template>
  </NCard>
</template>
