<script setup lang="ts">
import { ref, h, inject, computed, onMounted } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core'
import {
  NDrawer, NDrawerContent,
} from 'naive-ui'
import {
  useAppDrawerOpened,
} from '@components/shared'


const isDrawerOpened = useAppDrawerOpened();
const breakpoints = useBreakpoints(breakpointsTailwind)
const isNotMobile = breakpoints.greaterOrEqual('md')

// Watchers and lifecycle

</script>

<template>
  <NDrawer
    v-model:show="isDrawerOpened"
    placement="right"
    :width="isNotMobile ? '400px' : '80%'"
  >
    <NDrawerContent
      :native-scrollbar="false"
      :body-content-style="{
        padding: '0',
        height: '100%',
        overflow: 'hidden',
      }"
    >
      <template #header>
        <slot name="header" />
      </template>
      <slot />
      <template #footer>
        <slot name="footer" />
      </template>
    </NDrawerContent>
  </NDrawer>
</template>
