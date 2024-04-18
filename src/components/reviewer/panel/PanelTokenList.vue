<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue'
import {
  NSkeleton, NEmpty, NButton,
} from 'naive-ui';
import { queryTokenList } from '@shared/flow/action/scripts';
import { FlowSrvKey } from '@shared/flow/utilitites';
import type { StandardTokenView } from '@shared/flow/entities';
import { FilterType } from '@shared/flow/enums';

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

const flowSrv = inject(FlowSrvKey);

const current = computed({
  get: () => props.ft,
  set: (v?: StandardTokenView) => {
    emits('update:ft', v)
  }
})

const isFirstLoading = ref(false)
const isLoading = ref(false)
const loadingSize = ref(100)
const hasMore = ref(false)
const currentPage = ref<number>(0)

const tokens = reactive<StandardTokenView[]>([])
const totalAmount = ref<number>(0)

async function loadTokenList() {
  isLoading.value = true
  const results = await queryTokenList(
    currentPage.value,
    loadingSize.value,
    props.reviewer,
    props.filterType
  )
  hasMore.value = results.list.length === loadingSize.value && currentPage.value * loadingSize.value < results.total
  totalAmount.value = results.total
  // update last start rank
  if (results.list.length > 0) {
    currentPage.value = currentPage.value ? currentPage.value + 1 : 1
    tokens.push(...results.list)
  }
  isLoading.value = false
}

async function reload() {
  isFirstLoading.value = true
  currentPage.value = 0
  tokens.splice(0, tokens.length)
  await loadTokenList()
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
  <div class="md:min-w-[10rem] max-w-[10rem] md:max-w-[20rem]">
    <div :class="['flex flex-col items-start gap-2', {
      'justify-center': tokens.length === 0,
    }]">
      <NSkeleton
        v-if="isFirstLoading"
        animate
        text
        :repeat="4"
      />
      <template v-else>
        <NEmpty
          v-if="tokens.length === 0"
          description="No Token Found"
          class="my-8"
        />
        <template v-else>
          <ItemTokenInfo
            v-for="token in tokens"
            :key="`${token.identity.address}.${token.identity.contractName}`"
            :token="token"
            class="w-full"
            :active="current?.identity.address === token.identity.address && current?.identity.contractName === token.identity.contractName"
            @select="current = token"
          />
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
        @click="loadTokenList"
      >
        Load More
      </NButton>
    </div>
  </div>
</template>
