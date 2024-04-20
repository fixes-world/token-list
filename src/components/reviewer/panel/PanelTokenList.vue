<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue'
import { NInput } from 'naive-ui'
import { queryTokenList } from '@shared/flow/action/scripts';
import type { StandardTokenView, QueryResult } from '@shared/flow/entities';
import { FilterType } from '@shared/flow/enums';

import ListWrapper from '@components/widgets/ListWrapper.vue';
import ItemTokenInfo from '@components/items/ItemTokenInfo.vue';

const props = withDefaults(defineProps<{
  ft?: StandardTokenView,
  reviewer?: string,
  filterType?: FilterType,
}>(), {
  ft: undefined,
  filterType: FilterType.ALL,
})

const emits = defineEmits<{
  (e: 'update:ft', v: StandardTokenView | undefined): void
}>()

const current = computed({
  get: () => props.ft,
  set: (v?: StandardTokenView) => {
    emits('update:ft', v)
  }
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
      emptyMessage="No Token Found"
      v-model:page="currentPage"
      :loadMore="loadTokenList"
      :filter="filterName"
      :getItemName="token => token.identity.contractName"
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
            <div class="i-carbon:search w-5 h-5 text-gray-400/50" />
          </template>
        </NInput>
      </template>
      <template #="{ items }">
        <ItemTokenInfo
          v-for="token in items"
          :key="`${token.identity.address}.${token.identity.contractName}`"
          :token="token"
          class="w-full"
          :active="current?.identity.address === token.identity.address && current?.identity.contractName === token.identity.contractName"
          @select="current = token"
        />
      </template>
    </ListWrapper>
  </div>
</template>
