<script setup lang="ts">
import { ref, computed, inject, onMounted } from 'vue';
import { NSkeleton, NEmpty, NCode } from 'naive-ui'
import hljs from 'highlight.js/lib/core';
import json from 'highlight.js/lib/languages/json';

import type { TokenList } from '@shared/flow/entities';
import { queryTokenList } from '@shared/api/utilties.client';

hljs.registerLanguage('json', json);

const isFirstLoading = ref(false)
const tokenList = ref<TokenList | null>(null)

const tokenListJson = computed(() => {
  if (!tokenList.value) return null
  return JSON.stringify(tokenList.value, null, 2)
})

async function loadJsonView() {
  isFirstLoading.value = true
  try {
    tokenList.value = await queryTokenList()
  } catch (e) {
    console.error(e)
    tokenList.value = null
  }
  isFirstLoading.value = false
}

onMounted(async () => {
  loadJsonView()
})

</script>

<template>
  <div class="w-full">
    <NSkeleton
      v-if="isFirstLoading"
      animated
      text
      :height="6"
      round
    />
    <NEmpty
      v-else-if="!tokenList"
      description="Failed to fetch the Token List"
      class="my-6"
    />
    <div
      v-else
      class="max-h-[calc(100vh-24rem)] overflow-x-auto overflow-y-scroll"
    >
      <NCode
        v-if="tokenListJson"
        :hljs="hljs"
        :code="tokenListJson"
        language="json"
        show-line-numbers
        word-wrap
      />
    </div>
  </div>
</template>
