<script setup lang="ts">
import { ref, computed } from 'vue'
import { NInput } from 'naive-ui';

const props = withDefaults(defineProps<{
  search?: string
}>(), {
  search: undefined
})

const emits = defineEmits<{
  (e: 'update:search', value?: string): void
}>()

const filterName = computed({
  get: () => props.search,
  set: (v?: string) => {
    emits('update:search', v)
  }
})
</script>

<template>
  <NInput
    size="small"
    round
    v-model:value="filterName"
    placeholder="Search"
    :input-props="{
      autocomplete: 'off', autocorrect: 'off', autocapitalize: 'off', spellcheck: 'false', inputmode: 'search', enterKeyHint: 'search'
    }"
    clearable
  >
    <template #suffix>
      <div class="i-carbon:search w-4 h-4 text-gray-400/50" />
    </template>
  </NInput>
</template>
