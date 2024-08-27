<script setup lang="ts">
import { ref, computed, inject, onMounted } from 'vue';
import type { TokenStatus } from '@shared/flow/entities';

import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import ElementAddressBrowserLink from '@components/items/cardElements/ElementAddressBrowserLink.vue';
import SelectTokenContracts from '@components/landing/items/SelectTokenContracts.vue';
import FromSubmitRegisterToken from '@components/landing/form/FromSubmitRegisterToken.vue';
import AddressSearch from '@components/landing/items/AddressSearch.vue';

// Reactive Variables
const contractsRef = ref<typeof SelectTokenContracts | null>(null)

const currentAddress = ref<string | undefined>(undefined);
const currentFTContract = ref<TokenStatus | undefined>(undefined)

// Handlers Functions

function refresh() {
  currentFTContract.value = undefined;
  contractsRef.value?.reload();
}

onMounted(() => {
  currentAddress.value = undefined;
});

</script>

<template>
  <div class="flex flex-col items-center justify-center gap-4 md:gap-6">
    <AddressSearch
      place-holder="Input Flow Address with Non-Fungible Token Contracts."
      @input="currentAddress = $event"
    />
    <ElementWrapper
      v-if="currentAddress"
      class="px-2 w-full"
      direction="col"
      position="left"
    >
      <template #title>
        <span class="px-1 inline-flex items-center gap-2 text-sm font-semibold">
          List of NFT Contracts in
          <ElementAddressBrowserLink :address="currentAddress" :short="false" />
        </span>
      </template>
      <SelectTokenContracts
        ref="contractsRef"
        :address="currentAddress"
        v-model:current="currentFTContract"
      />
    </ElementWrapper>
    <FromSubmitRegisterToken
      v-if="currentFTContract"
      :token="currentFTContract"
      @success="refresh"
    />
    <p class="px-4 text-xs text-gray-400">
      <span class="i-carbon:warning w-3 h-3" /> If the non-fungible token contract is implemented with
      <a
        href="https://github.com/onflow/flow-nft/blob/master/contracts/ViewResolver.cdc"
        class="highlight"
        target="_blank"
      >ViewResolver</a>
      interface, the <strong>NFTCollectionData</strong> and <strong>NFTCollectionDisplay</strong> from
      <a
        href="https://github.com/onflow/flow-nft/blob/master/contracts/MetadataViews.cdc"
        class="highlight"
        target="_blank"
      >MetadataViews</a>
      will be automatically fetched from the contract.
    </p>
  </div>
</template>
