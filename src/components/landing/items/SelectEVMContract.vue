<script setup lang="ts">
import { computed, h, ref, inject, onMounted, watch, type VNodeChild, toRaw } from 'vue';
import {
  NSkeleton, NEmpty,
} from 'naive-ui';
import { getEVMFTOrNFTContract } from '@shared/flow/action/scripts'
import type { EVMAssetStatus } from '@shared/flow/entities';

import ItemEVMAssetStatus from '@components/items/ItemEVMAssetStatus.vue';

const props = withDefaults(defineProps<{
  address?: string;
  disabled?: boolean;
  current?: EVMAssetStatus;
}>(), {
  disabled: false,
});

const emits = defineEmits<{
  (e: 'update:current', value?: EVMAssetStatus): void;
}>();

// Reactive Variables

const isLoadingData = ref(false);

const currentContract = computed({
  get() {
    return props.current;
  },
  set(value) {
    emits('update:current', value);
  },
})

const isDisabled = computed(() => {
  return props.disabled || !currentContract.value
})

// Handlers Functions

async function reload() {
  if (!props.address) {
    return;
  }
  await loadAssetContracts(props.address);
}

async function loadAssetContracts(addr: string) {
  if (!addr) {
    return;
  }
  console.log('Loading contracts from Address:', addr)

  isLoadingData.value = true;
  currentContract.value = await getEVMFTOrNFTContract(addr)
  isLoadingData.value = false;
}

// Watchers and Life Cycle Hooks

watch(() => props.address, async (address) => {
  if (!address) {
    return;
  }

  await loadAssetContracts(address);
}, { immediate: true });

// Expose to parent component

defineExpose({
  reload,
})

</script>

<template>
  <div
    class="w-full"
    v-if="!!address"
  >
    <NSkeleton
      v-if="isLoadingData"
      animated
      text
      :height="6"
      round
    />
    <template v-else-if="!currentContract">
      <NEmpty
        description="Failed to fetch Contracts automatically"
        class="my-6"
      />
    </template>
    <ItemEVMAssetStatus
      v-else
      :item="currentContract"
    />
  </div>
</template>
