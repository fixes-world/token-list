<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import { NTabs, NTabPane, NDivider, NSwitch } from 'naive-ui'

import VueWrapper from '@components/partials/VueWrapper.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import CodeBlock from '@components/widgets/CodeBlock.vue';
import { getQueryListScript } from '@shared/flow/action/scripts';

const breakpoints = useBreakpoints(breakpointsTailwind)
const isOnPCBrowser = breakpoints.greaterOrEqual('lg')

// tabs
type TabType = 'cadence' | 'js' | 'python' | 'curl'
const currentTab = ref<TabType>('js')

// Reactive Data

const isNFT = ref(false)
const isEVMOnly = ref(false)

const apiName = computed(() => {
  return isNFT.value ? 'nft-list' : 'token-list'
})
const scriptPath = computed(() => {
  return isNFT.value
    ? (!isEVMOnly.value ? 'nftlist/query-token-list' : 'query-evm-bridged-nft-list')
    : (!isEVMOnly.value ? 'query-token-list' : 'query-evm-bridged-ft-list')
})

const endpoint = computed(() => {
  const baseUrl = window.location.origin
  return `${baseUrl}/api/${apiName.value}`
})

const endpointFull = computed(() => {
  return endpoint.value + `[/:reviewer]?[${isEVMOnly.value ? 'evm=true' : 'filter='}][&page=][&limit=]`
})

const endpointInCode = computed(() => {
  return endpoint.value + `?${isEVMOnly.value ? 'evm=true' : 'filter=0'}`
})

const queryScriptGithubLink = computed(() => {
  return `https://github.com/fixes-world/token-list/blob/main/cadence/scripts/${scriptPath.value}.cdc`
})

const cadenceCode = computed(() => {
  return getQueryListScript(isNFT.value, isEVMOnly.value)
})

const javaScriptCode = computed(() => {
  // The JavaScript Code to fetch the token list by GET method
  return `
const response = await fetch('${endpointInCode.value}')
const tokenList = await response.json()
  `
})

const pythonCode = computed(() => {
  // The Python Code to fetch the token list by GET method
  return `
import requests

response = requests.get('${endpointInCode.value}')
token_list = response.json()
  `
})

const curlCode = computed(() => {
  // The CURL Command to fetch the token list by GET method
  return `
curl -X GET '${endpointInCode.value}'
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
  <VueWrapper id="HowToUseSection">
    <div :class="['relative mx-a max-w-4xl',
      'flex flex-col items-center justify-start',
      'w-full sm:w-[95%] md:w-[90%] lg:w-[85%] xl:w-[80%]',
    ]">
      <div class="w-full flex flex-col gap-2 text-xs">
        <div class="flex gap-2">
          <ElementWrapper
            title="For"
            direction="auto"
            position="left"
          >
            <NSwitch
              size="small"
              v-model:value="isNFT"
            >
              <template #checked>
                <span class="text-xs">Non-Fungible Token</span>
              </template>
              <template #unchecked>
                <span class="text-xs">Fungible Token</span>
              </template>
            </NSwitch>
          </ElementWrapper>
          <ElementWrapper
            title="with"
            direction="auto"
            position="left"
          >
            <NSwitch
              size="small"
              v-model:value="isEVMOnly"
            >
              <template #checked>
                <span class="text-xs">EVM Only</span>
              </template>
              <template #unchecked>
                <span class="text-xs">All Tokens</span>
              </template>
            </NSwitch>
          </ElementWrapper>
        </div>
        <ElementWrapper
          title="Cadence"
          direction="auto"
          position="left"
        >
          <a
            class="font-semibold"
            :href="queryScriptGithubLink"
            target="_blank"
          >{{ queryScriptGithubLink }}</a>
        </ElementWrapper>
        <ElementWrapper
          title="API Endpoint"
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
          >API Reference</a>
        </ElementWrapper>
      </div>
      <NDivider title-placement="left">
        <span class="text-xs italic text-gray-500">Sample Codes</span>
      </NDivider>
      <NTabs
        type="line"
        display-directive="show:lazy"
        v-model:value="currentTab"
        :size="isOnPCBrowser ? 'large' : 'medium'"
        :justify-content="isOnPCBrowser ? undefined : 'space-evenly'"
      >
        <NTabPane
          name="cadence"
          tab="Cadence"
        >
          <CodeBlock
            language="javascript"
            :code="cadenceCode"
            :use-dark="false"
          />
        </NTabPane>
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
      </NTabs>
      <NDivider title-placement="left">
        <span class="text-xs italic text-gray-500">Static JSON Files</span>
      </NDivider>
      <div class="w-full space-y-2">
        <ElementWrapper
          title="Github Repo:"
          direction="auto"
          position="left"
        >
          <a
            class="font-semibold"
            href="https://github.com/fixes-world/token-list-jsons"
            target="_blank"
          >
            https://github.com/fixes-world/token-list-jsons
          </a>
        </ElementWrapper>
        <p class="text-sm text-gray-400">
          You can also use the daily synced static JSON files of the token list.
        </p>
      </div>
    </div>
  </VueWrapper>
</template>
