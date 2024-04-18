<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import { NTabs, NTabPane, NDivider, NCode } from 'naive-ui'

import VueWrapper from '@components/partials/VueWrapper.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import CodeBlock from '@components/widgets/CodeBlock.vue';

const breakpoints = useBreakpoints(breakpointsTailwind)
const isOnPCBrowser = breakpoints.greaterOrEqual('lg')

// tabs
type TabType = 'js' | 'python' | 'curl' | 'go'
const currentTab = ref<TabType>('js')

// Reactive Data

const endpoint = computed(() => {
  const baseUrl = window.location.origin
  return `${baseUrl}/api/token-list`
})

const endpointFull = computed(() => {
  return endpoint.value + '[/:reviewer][?filter=][&page=][&limit=]'
})

const javaScriptCode = computed(() => {
  return `
  let s = "a";
  `
})

const pythonCode = computed(() => {
  return `
  `
})

const curlCode = computed(() => {
  return `
  `
})

const goCode = computed(() => {
  return `
  `
})

// Functions

function copyToClipboard(text: string) {
  navigator.clipboard.writeText(text)
}

// Watchers and Lifecycle Hooks

onMounted(() => {
  // TODO
});

</script>

<template>
  <VueWrapper>
    <div :class="[
      'relative mx-a max-w-xl',
      'flex flex-col items-center justify-center',
      'w-full sm:w-[90%] md:w-[80%] lg:w-[70%] xl:w-[60%]',
    ]">
      <NTabs
        type="line"
        display-directive="show:lazy"
        v-model:value="currentTab"
        :size="isOnPCBrowser ? 'large' : 'medium'"
        :justify-content="isOnPCBrowser ? undefined : 'space-evenly'"
      >
        <NTabPane
          name="js"
          tab="JavaScript"
        >
          <CodeBlock
            language="javascript"
            :code="javaScriptCode"
            :use-dark="false"
          />
        </NTabPane>
        <NTabPane
          name="python"
          tab="Python"
        >
          <CodeBlock
            language="python"
            :code="pythonCode"
            :use-dark="false"
          />
        </NTabPane>
        <NTabPane
          name="curl"
          tab="CURL"
        >
          <CodeBlock
            language="bash"
            :code="curlCode"
            :use-dark="false"
          />
        </NTabPane>
        <NTabPane
          name="go"
          tab="Golang"
        >
          <CodeBlock
            language="go"
            :code="goCode"
            :use-dark="false"
          />
        </NTabPane>
      </NTabs>
      <NDivider title-placement="left">
        <span class="text-xs italic text-gray-500">API Endpoint</span>
      </NDivider>
      <div class="w-full flex flex-col gap-2 text-xs">
        <ElementWrapper
          title="URL"
          direction="auto"
          position="left"
        >
          <span class="font-semibold">{{ endpointFull }}</span>
        </ElementWrapper>
        <ElementWrapper
          title="Learn More"
          direction="auto"
          position="left"
        >
          <a
            class="font-semibold highlight"
            href="https://docs.fixes.world/concepts/token-list"
            target="_blank"
          >Reference</a>
        </ElementWrapper>
      </div>
    </div>
  </VueWrapper>
</template>
