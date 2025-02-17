<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue'
import { queryNFTList, queryTokenList } from '@shared/flow/action/scripts';
import type { StandardTokenView, QueryResult, StandardNFTCollectionView } from '@shared/flow/entities';
import { FilterType } from '@shared/flow/enums';

import ListWrapper from '@components/widgets/ListWrapper.vue';
import ItemTokenInfo from '@components/items/ItemTokenInfo.vue';
import ItemNFTCollectionInfo from '@components/items/ItemNFTCollectionInfo.vue';
import SearchFilter from '@components/landing/items/SearchFilter.vue';

const props = withDefaults(defineProps<{
  reviewer?: string,
  filterType?: FilterType,
  isNft?: boolean,
  ft?: StandardTokenView,
  nft?: StandardNFTCollectionView,
}>(), {
  isNft: false,
  filterType: FilterType.ALL,
  ft: undefined,
  nft: undefined,
})

const emits = defineEmits<{
  (e: 'update:ft', v: StandardTokenView | undefined): void
  (e: 'update:nft', v: StandardNFTCollectionView | undefined): void
}>()

const currentFT = computed({
  get: () => props.ft,
  set: (v?: StandardTokenView) => {
    emits('update:ft', v)
  }
})

const currentNFT = computed({
  get: () => props.nft,
  set: (v?: StandardNFTCollectionView) => {
    emits('update:nft', v)
  }
})

const currentIdentity = computed(() => {
  return props.isNft ? currentNFT.value?.identity : currentFT.value?.identity
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

async function loadList(page: number, size: number) {
  if (props.isNft) {
    return await loadNFTList(page, size)
  } else {
    return await loadTokenList(page, size)
  }
}

async function reload() {
  await listWrapperRef.value?.reload()
}

// Watchers and Lifecycle

defineExpose({
  reload,
})
</script>

<template>
  <div class="max-h-[calc(100vh)] w-[10rem] md:w-[14rem] overflow-x-auto overflow-y-scroll">
    <ListWrapper
      ref="listWrapperRef"
      emptyMessage="No List Found"
      v-model:page="currentPage"
      :loadMore="loadList"
      :filter="filterName"
      :getItemName="token => `${token.display?.display?.symbol ?? ''}:${token.identity.contractName}`"
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
          :active="currentIdentity?.address === token.identity.address && currentIdentity?.contractName === token.identity.contractName"
          @select="() => props.isNft ? currentNFT = token : currentFT = token"
        />
      </template>
    </ListWrapper>
  </div>
</template>
