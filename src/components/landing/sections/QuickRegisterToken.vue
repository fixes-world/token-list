<script setup lang="ts">
import { ref, computed, inject, onMounted } from 'vue';
import { NInput } from 'naive-ui'
import type { TokenStatus } from '@shared/flow/entities';

import VueWrapper from '@components/partials/VueWrapper.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import ElementAddressBrowserLink from '@components/items/cardElements/ElementAddressBrowserLink.vue';
import SelectTokenContracts from '@components/landing/items/SelectTokenContracts.vue';
import FromSubmitRegisterToken from '@components/landing/form/FromSubmitRegisterToken.vue';

// Reactive Variables
const contractsRef = ref<typeof SelectTokenContracts | null>(null)

const addressSearching = ref('');
const addressPlaceHolder = ref('Input Flow Address with Fungible Token Contracts.');
const currentAddress = ref<string | undefined>(undefined);
const currentFTContract = ref<TokenStatus | undefined>(undefined)

// Handlers Functions
function onHandleKeyup(e: KeyboardEvent) {
  e.preventDefault();

  const address = addressSearching.value;
  const regExp = /0x[a-fA-F0-9]{16}/ig;
  if (!regExp.test(address)) {
    addressSearching.value = '';
    addressPlaceHolder.value = 'Invalid Address: please try again.';
    currentAddress.value = undefined;
  } else {
    // Go to the next step
    currentAddress.value = address;
  }
}

function refresh() {
  currentFTContract.value = undefined;
  contractsRef.value?.reload();
}

onMounted(() => {
  currentAddress.value = undefined;
});

</script>

<template>
  <VueWrapper>
    <div :class="['relative mx-a max-w-xl',
      'flex flex-col items-center justify-center gap-4 md:gap-6',
      'w-full sm:w-[90%] md:w-[80%] lg:w-[70%] xl:w-[60%]',
    ]">
      <NInput
        passively-activated
        size="large"
        round
        v-model:value="addressSearching"
        :placeholder="addressPlaceHolder"
        :input-props="{
          autocomplete: 'off', autocorrect: 'off', autocapitalize: 'off', spellcheck: 'false', inputmode: 'search', enterKeyHint: 'search'
        }"
        @keyup.enter="onHandleKeyup"
      >
        <template #suffix>
          <div class="i-carbon:search w-5 h-5" />
        </template>
      </NInput>
      <ElementWrapper
        v-if="currentAddress"
        class="px-2 w-full"
        direction="col"
        position="left"
      >
        <template #title>
          <span class="px-1 inline-flex items-center gap-2 text-sm font-semibold">
            List of FT Contracts in
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
        <span class="i-carbon:warning w-3 h-3" />
        If the fungible token contract is implemented with
        <a
          href="https://github.com/onflow/flow-nft/blob/master/contracts/ViewResolver.cdc"
          class="highlight"
          target="_blank"
        >ViewResolver</a> interface,
        the metadata of <a
          href="https://github.com/onflow/flow-ft/blob/master/contracts/FungibleTokenMetadataViews.cdc"
          class="highlight"
          target="_blank"
        >FungibleTokenMetadataViews</a> will be automatically fetched from the contract.
      </p>
    </div>
  </VueWrapper>
</template>
