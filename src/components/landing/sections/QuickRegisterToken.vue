<script setup lang="ts">
import { ref, computed, inject, onMounted } from 'vue';
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';

import VueWrapper from '@components/partials/VueWrapper.vue';
import PanelRegisterAsset from '@components/landing/panels/PanelRegisterAsset.vue';

const breakpoints = useBreakpoints(breakpointsTailwind)
const isOnPCBrowser = breakpoints.greaterOrEqual('lg')

// Reactive Variables

</script>

<template>
  <VueWrapper id="QuickRegisterToken">
    <div :class="[
      'relative mx-a max-w-3xl',
      'w-full sm:w-[95%] md:w-[90%] lg:w-[85%] xl:w-[80%]',
    ]">
      <PanelRegisterAsset />
    </div>
  </VueWrapper>
</template>
