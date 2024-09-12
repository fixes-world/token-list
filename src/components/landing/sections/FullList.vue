<script setup lang="ts">
import { ref, computed, inject, onMounted } from 'vue';
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import { NTabs, NTabPane, NSwitch } from 'naive-ui'

import type { ReviewerInfo } from '@shared/flow/entities';

import VueWrapper from '@components/partials/VueWrapper.vue';
import ItemTabName from '@components/items/ItemTabName.vue';
import PanelTokensJsonView from '../panels/PanelTokensJsonView.vue';
import PanelTokensListView from '../panels/PanelTokensListView.vue';
import SelectReviewers from '@components/landing/items/SelectReviewers.vue';

const breakpoints = useBreakpoints(breakpointsTailwind)
const isOnPCBrowser = breakpoints.greaterOrEqual('lg')

// tabs
type TabType = 'jsonView' | 'listView'
const currentTab = ref<TabType>('listView')

const currentReviewer = ref<ReviewerInfo | undefined>(undefined)
const isShowEvmOnly = ref<boolean>(false)

const tabs = computed(() => {
  return [
    { key: 'listView', label: 'List View', icon: 'i-carbon:list', component: PanelTokensListView },
    { key: 'jsonView', label: 'JSON View', icon: 'i-carbon:json', component: PanelTokensJsonView },
  ]
})

// Functions

// Watchers and Lifecycle Hooks

onMounted(() => {
  // TODO
});

</script>

<template>
  <VueWrapper id="FullListSection">
    <div :class="[
      'relative mx-a max-w-3xl pt-4',
      'flex flex-col items-center justify-center',
      'w-full sm:w-[95%] md:w-[90%] lg:w-[85%] xl:w-[80%]',
    ]">
      <p class="absolute -top-8 px-2 text-xs text-gray-400">
        <span class="i-carbon:warning w-3 h-3" />
        You can preview the on-chain Fungible Token List here. The querying API has a cache time of 1 minute for efficiency improvement.
        Learn about
        <a
          href="/#how-to-use"
          class="highlight"
          target="_self"
        >How to use</a> below.
      </p>
      <SelectReviewers v-model:current="currentReviewer" />
      <NTabs
        type="line"
        display-directive="show:lazy"
        v-model:value="currentTab"
        :size="isOnPCBrowser ? 'large' : 'medium'"
        :justify-content="isOnPCBrowser ? undefined : 'space-evenly'"
      >
        <template #suffix>
          <NSwitch
            size="small"
            v-model:value="isShowEvmOnly"
          >
            <template #checked>
              <span class="text-xs">EVM Only</span>
            </template>
            <template #unchecked>
              <span class="text-xs">All Tokens</span>
            </template>
          </NSwitch>
        </template>
        <NTabPane
          v-for="item of tabs"
          :key="item.key"
          :name="item.key"
        >
          <template #tab>
            <ItemTabName :label="item.label">
              <template #icon>
                <span :class="['w-5 h-5', item.icon]" />
              </template>
            </ItemTabName>
          </template>
          <h2
            aria-level="2"
            class="block lg:hidden font-semibold text-lg italic mx-2 mb-3 mt-1"
          >{{ item.label }}</h2>
          {{ currentReviewer?.address }}
          {{ isShowEvmOnly }}
          <component
            :is="item.component"
            class="max-h-[calc(100vh-24rem)]"
            :reviewer="currentReviewer?.address"
            :is-evm-only="isShowEvmOnly"
          />
        </NTabPane>
      </NTabs>
    </div>
  </VueWrapper>
</template>
