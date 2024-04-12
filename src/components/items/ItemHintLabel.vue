<script setup lang="ts">
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import { NTooltip } from 'naive-ui'
import { computed } from 'vue';

const props = withDefaults(defineProps<{
  trigger?: 'hover' | 'click' | 'focus',
  colorStyle?: 'default' | 'highlight' | 'grey',
  maxWidth?: string,
  placement?: 'top' | 'bottom' | 'left' | 'right',
  withWarningIcon?: boolean,
}>(), {
  trigger: 'hover',
  colorStyle: 'default',
  maxWidth: undefined,
  placement: 'top',
  withWarningIcon: true,
})

const breakpoints = useBreakpoints(breakpointsTailwind)
const isOnPCBrowser = breakpoints.greaterOrEqual('lg')

const calcMaxWidth = computed(() => props.maxWidth ?? (isOnPCBrowser.value ? '420px' : '320px'))
</script>

<template>
  <NTooltip :trigger="trigger" :style="{ maxWidth: calcMaxWidth }" :placement="placement">
    <template #trigger>
      <span :class="[
      'inline-flex items-center gap-1',
      {
        'text-[var(--primary-color)]': colorStyle === 'highlight',
        'text-gray-400': colorStyle === 'grey'
      },
    ]">
        <slot />
        <span v-if="withWarningIcon" class="i-carbon:warning" />
        <slot name="suffix" />
      </span>
    </template>
    <slot name="hint" />
  </NTooltip>
</template>
