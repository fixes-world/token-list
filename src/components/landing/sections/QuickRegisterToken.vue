<script setup lang="ts">
import { ref, computed, inject, onMounted } from 'vue';
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import { NTabs, NTabPane } from 'naive-ui';

import VueWrapper from '@components/partials/VueWrapper.vue';
import ItemTabName from '@components/items/ItemTabName.vue';
import PanelRegisterFT from '@components/landing/panels/PanelRegisterFT.vue';
import PanelRegisterNFT from '@components/landing/panels/PanelRegisterNFT.vue';

const breakpoints = useBreakpoints(breakpointsTailwind)
const isOnPCBrowser = breakpoints.greaterOrEqual('lg')

// Reactive Variables

const currentTab = ref<'ft' | 'nft'>('ft')

const tabs = computed(() => {
  return [
    { key: 'ft', label: 'Fungible Token', icon: 'i-carbon:currency', component: PanelRegisterFT },
    { key: 'nft', label: 'Non-Fungible Token', icon: 'i-carbon:cube', component: PanelRegisterNFT },
  ]
})

</script>

<template>
  <VueWrapper id="QuickRegisterToken">
    <div :class="[
      'relative mx-a max-w-3xl',
      'w-full sm:w-[95%] md:w-[90%] lg:w-[85%] xl:w-[80%]',
    ]">
      <NTabs
        type="line"
        display-directive="show:lazy"
        v-model:value="currentTab"
        :size="isOnPCBrowser ? 'large' : 'medium'"
        :justify-content="isOnPCBrowser ? undefined : 'space-evenly'"
      >
        <NTabPane
          v-for="item of tabs"
          :key="item.key"
          :name="item.key"
        >
          <template #tab>
            <ItemTabName :label="item.label">
              <template #icon>
                <span :class="[item.icon, 'w-5 h-5']" />
              </template>
            </ItemTabName>
          </template>
          <h2
            aria-level="2"
            class="block lg:hidden font-semibold text-lg italic mx-2 mb-3 mt-1"
          >{{ item.label }}</h2>
          <component :is="item.component"></component>
        </NTabPane>
      </NTabs>
    </div>
  </VueWrapper>
</template>
