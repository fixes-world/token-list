<script setup lang="ts">
import { ref, computed, reactive, onMounted, watch } from 'vue';
import { NInput } from 'naive-ui'

import type { QueryResult, StandardTokenView, StandardNFTCollectionView } from '@shared/flow/entities';
import { queryTokenList, queryNFTList } from '@shared/flow/action/scripts';
import { FilterType } from '@shared/flow/enums';

import ListWrapper from '@components/widgets/ListWrapper.vue';
import ItemTokenInfo from '@components/items/ItemTokenInfo.vue';
import ItemNFTCollectionInfo from '@components/items/ItemNFTCollectionInfo.vue';

const props = withDefaults(defineProps<{
  isNft?: boolean,
  reviewer?: string,
  filterType?: FilterType,
}>(), {
  isNft: false,
  reviewer: undefined,
  filterType: FilterType.ALL,
})

const listWrapperRef = ref<typeof ListWrapper | null>(null)

const currentPage = ref<number>(0)
const filterName = ref<string>("")

async function loadTokenList(page: number, size: number): Promise<QueryResult<StandardTokenView>> {
  return await queryTokenList(
    page,
    size,
    props.reviewer,
    props.filterType
  )
}

async function loadNFTList(page: number, size: number): Promise<QueryResult<StandardNFTCollectionView>> {
  return await queryNFTList(
    page,
    size,
    props.reviewer,
    props.filterType
  )
}

async function loadMoreFunc(page: number, size: number) {
  if (props.isNft) {
    return await loadNFTList(page, size)
  } else {
    return await loadTokenList(page, size)
  }
}

async function reload() {
  listWrapperRef.value?.reload()
}

// Watchers and Lifecycle

watch(() => props.reviewer, async (newVal, oldVal) => {
  if (newVal !== oldVal) {
    await reload()
  }
})

defineExpose({
  reload,
})
</script>

<template>
  <div class="w-full overflow-x-auto overflow-y-scroll">
    <ListWrapper
      ref="listWrapperRef"
      emptyMessage="No Token Found"
      v-model:page="currentPage"
      :loadMore="loadMoreFunc"
      :filter="filterName"
      :getItemName="token => {
        return token.display?.display?.symbol ?? token.identity.contractName
      }"
    >
      <template #header>
        <NInput
          size="small"
          round
          v-model:value="filterName"
          placeholder="Search"
          :input-props="{
            autocomplete: 'off', autocorrect: 'off', autocapitalize: 'off', spellcheck: 'false', inputmode: 'search', enterKeyHint: 'search'
          }"
        >
          <template #suffix>
            <div class="i-carbon:search w-4 h-4 text-gray-400/50" />
          </template>
        </NInput>
      </template>
      <template #="{ items }">
        <component
          class="w-full"
          v-for="token in items"
          :key="`${token.identity.address}.${token.identity.contractName}`"
          :is="props.isNft ? ItemNFTCollectionInfo : ItemTokenInfo"
          :token="token"
          :hoverable="false"
          :withDisplay="true"
        />
      </template>
    </ListWrapper>
  </div>
</template>
