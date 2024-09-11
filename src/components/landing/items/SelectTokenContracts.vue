<script setup lang="ts">
import { computed, h, ref, inject, onMounted, watch, type VNodeChild, toRaw } from 'vue';
import {
  NSkeleton, NEmpty, NTag,
  NSelect, type SelectOption,
} from 'naive-ui';
import { getContractNames, getAssetContractStatus, getAssetsContracts } from '@shared/flow/action/scripts'
import type { TokenAssetStatus } from '@shared/flow/entities';

import ItemNativeAssetStatus from '@components/items/ItemNativeAssetStatus.vue';

const props = withDefaults(defineProps<{
  address?: string;
  disabled?: boolean;
  current?: TokenAssetStatus;
}>(), {
  disabled: false,
});

const emits = defineEmits<{
  (e: 'update:current', value?: TokenAssetStatus): void;
}>();

// Reactive Variables

const isLoadingData = ref(false);
const contracts = ref<TokenAssetStatus[]>([]);
const allContractNames = ref<string[]>([]);

const options = computed<SelectOption[]>(() => {
  return contracts.value?.map((contract) => {
    let identifier = `${contract.address}.${contract.contractName}`
    return {
      label: identifier,
      value: identifier,
      disabled: contract.isRegisteredWithNativeViewResolver && contract.isBridged,
    }
  }) || [];
})

const isDisabled = computed(() => {
  return props.disabled || contracts.value?.length === 0
})

const currentSelect = computed({
  get() {
    if (!props.current) return undefined
    return `${props.current.address}.${props.current.contractName}`;
  },
  set(value) {
    if (!value) {
      emits('update:current', undefined);
      return;
    }
    const [address, contractName] = value.split('.');
    emits('update:current', getData(address, contractName));
  },
});

// Handlers Functions

function getData(address: string, contractName: string): TokenAssetStatus | undefined {
  return contracts.value?.find((contract) => {
    return contract.address === address && contract.contractName === contractName;
  });
}

async function reload() {
  if (!props.address) {
    return;
  }
  await loadAssetContracts(props.address);
}

async function loadAssetContracts(addr: string) {
  console.log('Loading contracts from Address:', addr)

  isLoadingData.value = true;
  contracts.value = await getAssetsContracts(addr);
  if (contracts.value.length > 0) {
    allContractNames.value = contracts.value.map((contract) => contract.contractName);
  } else {
    allContractNames.value = await getContractNames(addr);
  }
  isLoadingData.value = false;
}

async function loadAssetStatus(addr: string, contractName: string) {
  console.log('Loading contract status:', addr, contractName)

  isLoadingData.value = true;
  const status = await getAssetContractStatus(addr, contractName);
  console.log('Loaded contract status:', status)
  if (status) {
    contracts.value = [status]
  }
  isLoadingData.value = false;
}

function renderLabel(option: SelectOption): VNodeChild {
  if (!option.value && !option.label) {
    return h('span', {}, undefined)
  }
  const [address, contractName] = (option.label as string)?.split('.');
  return h(ItemNativeAssetStatus, {
    item: getData(address, contractName),
  })
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
    <template v-else-if="contracts.length === 0">
      <NEmpty
        description="Failed to fetch FT/NFT Contracts automatically"
        class="my-6"
      />
      <template v-if="allContractNames.length > 0">
        <p class="mb-2 text-gray-400 italic font-semibold">
          Try click the contract name to load again
        </p>
        <div class="flex flex-wrap items-center gap-2">
          <NTag
            v-for="name in allContractNames"
            type="primary"
            size="small"
            round
            class="!cursor-pointer"
            @click="loadAssetStatus(address, name)"
          >
            {{ name }}
          </NTag>
        </div>
      </template>
    </template>
    <NSelect
      v-else
      size="large"
      v-model:value="currentSelect"
      :options="options"
      :loading="isLoadingData"
      :disabled="isDisabled"
      :placeholder="contracts.length === 0 ? 'No FT/NFT Contract Found' : 'Select FT/NFT Contract'"
      :render-label="renderLabel"
      :input-props="{ autocomplete: 'off' }"
      filterable
      clearable
    />
  </div>
</template>
