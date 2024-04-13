<script setup lang="ts">
import { ref, computed, inject, onMounted } from 'vue';
import { NInput } from 'naive-ui'
import type { TokenStatus } from '@shared/flow/entities';

import VueWrapper from '@components/partials/VueWrapper.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import ElementAddressBrowserLink from '@components/items/cardElements/ElementAddressBrowserLink.vue';
import SelectTokenContracts from '@components/landing/items/SelectTokenContracts.vue';

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

onMounted(() => {
  currentAddress.value = undefined;
});

</script>

<template>
  <VueWrapper>
    <div :class="[
      'mx-a max-w-xl w-full sm:w-[90%] md:w-[80%] lg:w-[70%] xl:w-[60%]',
      'flex flex-col items-center justify-center gap-4 md:gap-6'
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
            <ElementAddressBrowserLink :address="currentAddress" />
          </span>
        </template>
        <SelectTokenContracts
          :address="currentAddress"
          v-model:current="currentFTContract"
        />
      </ElementWrapper>
    </div>
  </VueWrapper>
</template>
