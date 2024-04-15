<script setup lang="ts">
import { ref, h, inject, computed } from 'vue'
import { navigate } from 'astro:transitions/client';
import { useEventBus, breakpointsTailwind, useBreakpoints } from '@vueuse/core'

import { useAppDrawerOpened } from '@components/shared'

import UserAddressWithAvatar from '@components/auth/UserAddressWithAvatar.vue'

const isDrawerOpened = useAppDrawerOpened();

const breakpoints = useBreakpoints(breakpointsTailwind)
const isWithAside = breakpoints.greaterOrEqual('md')

// Watchers and lifecycle

</script>

<template>
  <UserAddressWithAvatar
    class="cursor-pointer"
    :short="!isWithAside"
    :is-aside="false"
    @click="isDrawerOpened = true"
  />
</template>
