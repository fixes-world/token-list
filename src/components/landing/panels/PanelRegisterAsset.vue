<script setup lang="ts">
import { ref, computed, inject, onMounted } from 'vue';
import type { EVMAssetStatus, TokenAssetStatus } from '@shared/flow/entities';

import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import ElementAddressBrowserLink from '@components/items/cardElements/ElementAddressBrowserLink.vue';
import AddressSearch from '@components/landing/items/AddressSearch.vue';
import SelectTokenContracts from '@components/landing/items/SelectTokenContracts.vue';
import SelectEVMContract from '../items/SelectEVMContract.vue';
import FromSubmitRegisterToken from '@components/landing/form/FromSubmitRegisterToken.vue';
import FromSubmitRegisterEVMAsset from '@components/landing/form/FromSubmitRegisterEVMAsset.vue';

// Reactive Variables
const contractsRef = ref<typeof SelectTokenContracts | null>(null)

const currentAddress = ref<string | undefined>(undefined);
const isCurrentAddressEVM = ref<boolean>(false);
const currentNativeContract = ref<TokenAssetStatus | undefined>(undefined)
const currentEVMContract = ref<EVMAssetStatus | undefined>(undefined)

// Handlers Functions

function refresh() {
  currentNativeContract.value = undefined;
  currentEVMContract.value = undefined;
  contractsRef.value?.reload();
}

function onInputAddress(value: { address: string, isEVM: boolean } | undefined) {
  if (!value) {
    currentAddress.value = undefined;
    return;
  }
  console.log('Selected Address:', currentAddress.value, 'isEVM:', isCurrentAddressEVM.value)
  currentAddress.value = value.address;
  isCurrentAddressEVM.value = value.isEVM;
}

onMounted(() => {
  currentAddress.value = undefined;
});

</script>

<template>
  <div class="flex flex-col items-center justify-center gap-4 md:gap-6">
    <AddressSearch
      place-holder="Input Flow/EVM Address with Fungible(ERC20) / Non-Fungible(ERC721) Token Contracts."
      @input="onInputAddress"
    />
    <ElementWrapper
      v-if="currentAddress"
      class="px-2 w-full"
      direction="col"
      position="left"
    >
      <template #title>
        <span class="px-1 inline-flex items-center gap-2 text-sm font-semibold">
          List of Asset Contracts in
          <ElementAddressBrowserLink :address="currentAddress" :short="false" />
        </span>
      </template>
      <SelectTokenContracts
        v-if="!isCurrentAddressEVM"
        ref="contractsRef"
        :address="currentAddress"
        v-model:current="currentNativeContract"
      />
      <SelectEVMContract
        v-else
        :address="currentAddress"
        v-model:current="currentEVMContract"
      />
    </ElementWrapper>
    <FromSubmitRegisterToken
      v-if="currentNativeContract"
      :token="currentNativeContract"
      @success="refresh"
    />
    <FromSubmitRegisterEVMAsset
      v-else-if="currentEVMContract"
      :token="currentEVMContract"
      @success="refresh"
    />
    <div class="w-full text-xs space-y-2">
      <p class="font-semibold opacity-70">
        <span class="i-carbon:warning w-4 h-4" /> Requirements for Cadence Assets:
      </p>
      <ul class="text-gray-400 list-disc px-4">
        <li>
          Fungible Token - The contract must be implemented with
          <a
            href="https://github.com/onflow/flow-nft/blob/master/contracts/ViewResolver.cdc"
            class="highlight"
            target="_blank"
          >ViewResolver</a> interface and <strong>FTDisplay</strong> and <strong>FTVaultData</strong>
          views from <a
            href="https://github.com/onflow/flow-ft/blob/master/contracts/FungibleTokenMetadataViews.cdc"
            class="highlight"
            target="_blank"
          >FungibleTokenMetadataViews</a> should be resolved.
        </li>
        <li>
          Non-Fungible Token - The contract must be implemented with
          <a
            href="https://github.com/onflow/flow-nft/blob/master/contracts/ViewResolver.cdc"
            class="highlight"
            target="_blank"
          >ViewResolver</a>
          interface and <strong>NFTCollectionData</strong> and
          <strong>NFTCollectionDisplay</strong> views from
          <a
            href="https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc"
            class="highlight"
            target="_blank"
          >MetadataViews</a> should be resolved.
        </li>
      </ul>
      <p class="font-semibold opacity-70">
        <span class="i-carbon:warning w-4 h-4" /> Requirements for EVM Assets:
      </p>
      <ul class="text-gray-400 list-disc px-4">
        <li>
          Fungible Token - The contract must be a standard ERC20 contract.
        </li>
        <li>
          Non-Fungible Token - The contract must be a standard ERC721 contract.
        </li>
      </ul>
    </div>
  </div>
</template>
