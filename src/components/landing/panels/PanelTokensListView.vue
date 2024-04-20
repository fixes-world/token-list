<script setup lang="ts">
import { ref, computed, reactive, onMounted, watch } from 'vue';
import { NInput } from 'naive-ui'

import type { StandardTokenView, QueryResult } from '@shared/flow/entities';
import { queryTokenList } from '@shared/flow/action/scripts';
import { FilterType } from '@shared/flow/enums';

import ItemTokenInfo from '@components/items/ItemTokenInfo.vue';
import ListWrapper from '@components/widgets/ListWrapper.vue';

const props = withDefaults(defineProps<{
  reviewer?: string,
  filterType?: FilterType,
}>(), {
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
      :loadMore="loadTokenList"
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
        <ItemTokenInfo
          v-for="token in items"
          :key="`${token.identity.address}.${token.identity.contractName}`"
          class="w-full"
          :token="token"
          :hoverable="false"
          :withDisplay="true"
        />
      </template>
    </ListWrapper>
  </div>
</template>
