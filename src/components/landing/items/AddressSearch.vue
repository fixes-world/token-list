<script setup lang="ts">
import { ref, computed, inject, onMounted, watch } from 'vue';
import { NInput } from 'naive-ui'

const props = withDefaults(defineProps<{
  placeHolder?: string
}>(), {
  placeHolder: 'Input Flow Address with Fungible Token Contracts.'
});

const emits = defineEmits<{
  (e: 'input', value: { address: string, isEVM: boolean } | undefined): void
}>();

// Reactive Variables

const addressSearching = ref('');
const currentAddressPlaceHolder = ref(props.placeHolder);

// Handlers Functions
function onHandleKeyup(e: KeyboardEvent) {
  e.preventDefault();

  const address = addressSearching.value;
  const flowRegExp = /^0x[a-fA-F0-9]{16}$/ig;
  const evmRegExp = /^0x[a-fA-F0-9]{40}$/ig;
  if (evmRegExp.test(address)) {
    // Go to the next step
    currentAddressPlaceHolder.value = props.placeHolder;
    emits('input', { address, isEVM: true });
  } else if (flowRegExp.test(address)) {
    // Go to the next step
    currentAddressPlaceHolder.value = props.placeHolder;
    emits('input', { address, isEVM: false });
  } else {
    addressSearching.value = '';
    currentAddressPlaceHolder.value = 'Invalid Address: please try again.';
    emits('input', undefined);
  }
}

watch(() => props.placeHolder, (value) => {
  currentAddressPlaceHolder.value = value;
});

</script>

<template>
  <NInput
    passively-activated
    size="large"
    round
    v-model:value="addressSearching"
    :placeholder="currentAddressPlaceHolder"
    :input-props="{
      autocomplete: 'off', autocorrect: 'off', autocapitalize: 'off', spellcheck: 'false', inputmode: 'search', enterKeyHint: 'search'
    }"
    @keyup.enter="onHandleKeyup"
  >
    <template #suffix>
      <div class="i-carbon:search w-5 h-5" />
    </template>
  </NInput>
</template>
