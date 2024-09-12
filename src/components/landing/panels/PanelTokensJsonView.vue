<script setup lang="ts">
import { ref, computed, inject, onMounted, watch } from 'vue';
import { NSkeleton, NEmpty, NCode } from 'naive-ui'

import { FilterType } from '@shared/flow/enums';
import { queryNFTListByAPI, queryTokenListByAPI } from '@shared/api/utilties.client';

import CodeBlock from '@components/widgets/CodeBlock.vue';

const props = withDefaults(defineProps<{
  isNft?: boolean,
  isEvmOnly?: boolean,
  reviewer?: string,
  filterType?: FilterType,
}>(), {
  isNft: false,
  isEvmOnly: false,
  reviewer: undefined,
  filterType: FilterType.ALL,
})

const isFirstLoading = ref(false)
const tokenList = ref<any>(null)

const tokenListJson = computed(() => {
  if (!tokenList.value) return null
  return JSON.stringify(tokenList.value, null, 2)
})

async function loadJsonView() {
  isFirstLoading.value = true
  try {
    tokenList.value = props.isNft
      ? await queryNFTListByAPI(props.reviewer, props.filterType, props.isEvmOnly)
      : await queryTokenListByAPI(props.reviewer, props.filterType, props.isEvmOnly)
  } catch (e) {
    console.error(e)
    tokenList.value = null
  }
  isFirstLoading.value = false
}

watch(() => [props.reviewer, props.isEvmOnly, props.filterType], async (newVal, oldVal) => {
  if (newVal[0] !== oldVal[0] || newVal[1] !== oldVal[1] || newVal[2] !== oldVal[2]) {
    await loadJsonView()
  }
}, { deep: true })

onMounted(async () => {
  await loadJsonView()
})

</script>

<template>
  <div class="w-full rounded-2 overflow-x-auto overflow-y-scroll">
    <NSkeleton
      v-if="isFirstLoading"
      animated
      height="10rem"
    />
    <NEmpty
      v-else-if="!tokenList"
      description="Failed to fetch the Token List"
      class="my-6"
    />
    <CodeBlock
      v-else-if="tokenListJson"
      :code="tokenListJson"
      language="json"
    />
  </div>
</template>
