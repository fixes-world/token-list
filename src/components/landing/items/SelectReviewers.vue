<script setup lang="ts">
import { computed, h, ref, inject, onMounted, watch, type VNodeChild, toRaw } from 'vue';
import {
  NSkeleton, NEmpty, NTag,
  NSelect, type SelectOption,
} from 'naive-ui';
import { getReviewers } from '@shared/flow/action/scripts'
import type { ReviewerInfo } from '@shared/flow/entities';

import ItemReviewerInfo from './ItemReviewerInfo.vue';

const props = withDefaults(defineProps<{
  disabled?: boolean;
  current?: ReviewerInfo;
}>(), {
  disabled: false,
});

const emits = defineEmits<{
  (e: 'update:current', value?: ReviewerInfo): void;
}>();

// Reactive Variables

const isFirstLoading = ref(false);
const isLoadingData = ref(false);
const reviewers = ref<ReviewerInfo[]>([]);

const options = computed<SelectOption[]>(() => {
  return reviewers.value?.map((one) => {
    return {
      label: () => h(ItemReviewerInfo, { current: one }),
      value: one.address,
    }
  }) || [];
})

const isDisabled = computed(() => {
  return props.disabled || reviewers.value?.length === 0
})

const currentSelect = computed({
  get() {
    if (!props.current) return undefined
    return props.current.address;
  },
  set(value) {
    if (!value) {
      emits('update:current', undefined);
      return;
    }
    emits('update:current', reviewers.value?.find((one) => one.address === value));
  },
});

// Handlers Functions

async function reload() {
  isFirstLoading.value = true;
  await loadReviewers();
  isFirstLoading.value = false;
}

async function loadReviewers() {
  isLoadingData.value = true;
  reviewers.value = await getReviewers();
  isLoadingData.value = false;
}

// Watchers and Life Cycle Hooks

onMounted(async () => {
  await reload()
})

// Expose to parent component

defineExpose({
  reload,
})

</script>

<template>
  <div class="w-full">
    <NSkeleton
      v-if="isFirstLoading"
      animated
      width="100%"
      :height="3"
      round
    />
    <template v-else-if="reviewers.length === 0">
      <NEmpty
        description="No Reviwer Found"
        class="my-3"
      />
    </template>
    <NSelect
      v-else
      size="large"
      v-model:value="currentSelect"
      :options="options"
      :loading="isLoadingData"
      :disabled="isDisabled"
      placeholder="Select a reviewer to see more details"
      :input-props="{ autocomplete: 'off' }"
      filterable
      clearable
    />
  </div>
</template>
