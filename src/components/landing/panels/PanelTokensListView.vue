<script setup lang="ts">
import { ref, computed, reactive, onMounted, watch, toRaw } from 'vue';

import type { QueryResult, StandardTokenView, StandardNFTCollectionView } from '@shared/flow/entities';
import { queryTokenList, queryNFTList, queryEVMBridgedFTList, queryEVMBridgedNFTList } from '@shared/flow/action/scripts';
import { FilterType } from '@shared/flow/enums';

import ListWrapper from '@components/widgets/ListWrapper.vue';
import ItemTokenInfo from '@components/items/ItemTokenInfo.vue';
import ItemNFTCollectionInfo from '@components/items/ItemNFTCollectionInfo.vue';
import SearchFilter from '@components/landing/items/SearchFilter.vue';

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

const listWrapperRef = ref<typeof ListWrapper | null>(null)

const currentPage = ref<number>(0)
const filterName = ref<string>("")

async function loadTokenList(page: number, size: number): Promise<QueryResult<StandardTokenView>> {
  return props.isEvmOnly
    ? await queryEVMBridgedFTList(page, size, props.reviewer)
    : await queryTokenList(page, size, props.reviewer, props.filterType)
}

async function loadNFTList(page: number, size: number): Promise<QueryResult<StandardNFTCollectionView>> {
  return props.isEvmOnly
    ? await queryEVMBridgedNFTList(page, size, props.reviewer)
    : await queryNFTList(page, size, props.reviewer, props.filterType)
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

watch(() => [props.reviewer, props.isEvmOnly, props.filterType], async (newVal, oldVal) => {
  if (newVal[0] !== oldVal[0] || newVal[1] !== oldVal[1] || newVal[2] !== oldVal[2]) {
    await reload()
  }
}, { deep: true })

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
        <SearchFilter v-model:search="filterName" />
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
