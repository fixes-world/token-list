<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { NInput, NSkeleton } from 'naive-ui'

import VueWrapper from '@components/partials/VueWrapper.vue';

const addressSearch = ref('');
const addressPlaceHolder = ref('0xabc...abc');
const isLoaded = ref(false);


// Handlers Functions
function onHandleKeyup(e: KeyboardEvent) {
  e.preventDefault();
  const address = addressSearch.value;
  const regExp = /0x[a-fA-F0-9]{16}/ig;
  if (!regExp.test(address)) {
    addressSearch.value = '';
    addressPlaceHolder.value = 'Invalid Address: please try again.';
    return;
  }
}

onMounted(() => {
  isLoaded.value = true;
});

</script>

<template>
  <VueWrapper class="mx-a flex flex-col items-center justify-center gap-8 md:gap-12">
    <div class="max-w-xl w-full sm:w-[90%] md:w-[80%] lg:w-[70%] xl:w-[60%]">
      <NInput v-if="isLoaded" passively-activated size="large" round v-model:value="addressSearch"
        :placeholder="addressPlaceHolder" :input-props="{
          autocomplete: 'off',
          autocorrect: 'off',
          autocapitalize: 'off',
          spellcheck: 'false',
          inputmode: 'search',
          enterKeyHint: 'search',
        }" @keyup.enter="onHandleKeyup">
        <template #suffix>
          <div class="i-carbon:search w-5 h-5" />
        </template>
      </NInput>
      <NSkeleton v-else animated height="40px" round />
    </div>
  </VueWrapper>
</template>
