<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue';
import { NSkeleton, NEmpty, NButton } from 'naive-ui'

import type { QueryResult } from '@shared/flow/entities';

const props = withDefaults(defineProps<{
  loadMore: (page: number, size: number) => Promise<QueryResult<any>>,
  page?: number,
  size?: number,
  emptyMessage?: string,
  filter?: string,
  getItemName?: (item: any) => string,
}>(), {
  page: 0,
  size: 50,
  emptyMessage: 'No Item Found',
  filter: "",
  getItemName: (item: any) => item.name,
})

const emits = defineEmits<{
  (e: 'update:page', v: number): void
}>()

const isFirstLoading = ref(false)
const isLoading = ref(false)
const hasMore = ref(false)

const currentPage = computed<number>({
  get() {
    return props.page
  },
  set(v) {
    emits('update:page', v)
  }
})

const list = reactive<any[]>([])
const totalAmount = ref<number>(0)

const filteredList = computed(() => {
  return !!props.filter ? list.filter((item) => {
    const name = props.getItemName(item)?.toLowerCase()
    return name.includes(props.filter.toLowerCase())
  }) : list
})

async function loadMore(forceFirst = false) {
  isLoading.value = true
  const results = await props.loadMore(
    forceFirst ? 0 : currentPage.value,
    props.size,
  )
  hasMore.value = results.list.length === props.size && currentPage.value * props.size < results.total
  totalAmount.value = results.total
  // update last start rank
  if (results.list.length > 0) {
    currentPage.value = currentPage.value && !forceFirst ? currentPage.value + 1 : 1
    list.push(...results.list)
  }
  isLoading.value = false
}

async function reload() {
  isFirstLoading.value = true
  list.splice(0, list.length)
  currentPage.value = 0
  await loadMore(true)
  isFirstLoading.value = false
}

// Watchers and Lifecycle

onMounted(async () => {
  await reload()
})

defineExpose({
  reload,
})
</script>

<template>
  <div :class="['flex flex-col items-start gap-2', {
    'justify-center': list.length === 0,
  }]">
    <slot name="header" />
    <NSkeleton
      v-if="isFirstLoading"
      animate
      text
      :repeat="4"
    />
    <template v-else>
      <NEmpty
        v-if="list.length === 0"
        :description="emptyMessage"
        class="my-8"
      />
      <template v-else>
        <slot :items="filteredList" />
      </template>
    </template>
  </div>
  <div
    v-if="hasMore"
    class="w-full mt-4 flex justify-center"
  >
    <NButton
      strong
      tertiary
      round
      size="large"
      :loading="isLoading"
      :disabled="isLoading"
      @click="() => loadMore()"
    >
      Load More
    </NButton>
  </div>
</template>
