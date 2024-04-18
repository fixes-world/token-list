<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue';
import { NSkeleton, NEmpty, NButton } from 'naive-ui'

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
      v-slot="{ items }"
    >
      <ItemTokenInfo
        v-for="token in items"
        :key="`${token.identity.address}.${token.identity.contractName}`"
        class="w-full"
        :token="token"
        :hoverable="false"
        :withIcon="true"
      />
    </ListWrapper>
  </div>
</template>
