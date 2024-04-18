<script setup lang="ts">
import { computed, h, ref, inject, onMounted, watch, type VNodeChild, toRaw } from 'vue';
import {
  NSkeleton, NEmpty, NTag,
  NSelect, type SelectOption,
} from 'naive-ui';
import { getContractNames, getFTContracts, getFTContractStatus } from '@shared/flow/action/scripts'
import { FlowSrvKey } from '@shared/flow/utilitites';
import type { TokenStatus } from '@shared/flow/entities';

import ItemFungibleTokenStatus from '@components/items/ItemFungibleTokenStatus.vue';

const props = withDefaults(defineProps<{
  address?: string;
  disabled?: boolean;
  current?: TokenStatus;
}>(), {
  disabled: false,
});

const emits = defineEmits<{
  (e: 'update:current', value?: TokenStatus): void;
}>();

// Reactive Variables

const isLoadingData = ref(false);
const ftContracts = ref<TokenStatus[]>([]);
const allContractNames = ref<string[]>([]);

const options = computed<SelectOption[]>(() => {
  return ftContracts.value?.map((contract) => {
    let identifier = `${contract.address}.${contract.contractName}`
    return {
      label: identifier,
      value: identifier,
      disabled: contract.isRegistered,
    }
  }) || [];
})

const isDisabled = computed(() => {
  return props.disabled || ftContracts.value?.length === 0
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
    emits('update:current', getFTData(address, contractName));
  },
});

// Handlers Functions

function getFTData(address: string, contractName: string): TokenStatus | undefined {
  return ftContracts.value?.find((contract) => {
    return contract.address === address && contract.contractName === contractName;
  });
}

async function reload() {
  if (!props.address) {
    return;
  }
  await loadFTContracts(props.address);
}

async function loadFTContracts(addr: string) {
  console.log('Loading contracts from Address:', addr)

  isLoadingData.value = true;
  ftContracts.value = await getFTContracts(addr);
  if (ftContracts.value.length > 0) {
    allContractNames.value = ftContracts.value.map((contract) => contract.contractName);
  } else {
    allContractNames.value = await getContractNames(addr);
  }
  isLoadingData.value = false;
}

async function loadFTStatus(addr: string, contractName: string) {
  console.log('Loading contract status:', addr, contractName)

  isLoadingData.value = true;
  const status = await getFTContractStatus(addr, contractName);
  if (status) {
    ftContracts.value = [status]
  }
  isLoadingData.value = false;
}

function renderLabel(option: SelectOption): VNodeChild {
  if (!option.value && !option.label) {
    return h('span', {}, undefined)
  }
  const [address, contractName] = (option.label as string)?.split('.');
  return h(ItemFungibleTokenStatus, {
    item: getFTData(address, contractName),
  })
}

// Watchers and Life Cycle Hooks

watch(() => props.address, async (address) => {
  if (!address) {
    return;
  }

  await loadFTContracts(address);
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
    <template v-else-if="ftContracts.length === 0">
      <NEmpty
        description="Failed to fetch FT Contracts automatically"
        class="my-6"
      />
      <template v-if="allContractNames.length > 0">
        <p class="mb-2 text-gray-400 italic font-semibold">Try click the contract name to load again</p>
        <div class="flex flex-wrap items-center gap-2">
          <NTag
            v-for="name in allContractNames"
            type="primary"
            size="small"
            round
            class="!cursor-pointer"
            @click="loadFTStatus(address, name)"
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
      :placeholder="ftContracts.length === 0
        ? 'No Fungible Token Contract Found'
        : 'Select Fungible Token'
        "
      :render-label="renderLabel"
      :input-props="{ autocomplete: 'off' }"
      filterable
      clearable
    />
  </div>
</template>
