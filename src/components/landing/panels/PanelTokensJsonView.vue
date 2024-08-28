<script setup lang="ts">
import { ref, computed, inject, onMounted, watch } from 'vue';
import { NSkeleton, NEmpty, NCode } from 'naive-ui'

import { FilterType } from '@shared/flow/enums';
import { queryNFTListByAPI, queryTokenListByAPI } from '@shared/api/utilties.client';

import CodeBlock from '@components/widgets/CodeBlock.vue';

const props = withDefaults(defineProps<{
  isNft?: boolean,
  reviewer?: string,
  filterType?: FilterType,
}>(), {
  isNft: false,
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
      ? await queryNFTListByAPI(props.reviewer, props.filterType)
      : await queryTokenListByAPI(props.reviewer, props.filterType)
  } catch (e) {
    console.error(e)
    tokenList.value = null
  }
  isFirstLoading.value = false
}

watch(() => props, async (newVal, oldVal) => {
  if (newVal.reviewer !== oldVal.reviewer || newVal.filterType !== oldVal.filterType || newVal.isNft !== oldVal.isNft) {
    await loadJsonView()
  }
})

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
