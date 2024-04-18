<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { NCode } from 'naive-ui'
import hljs from 'highlight.js/lib/core';

const props = withDefaults(defineProps<{
  code: string,
  language: 'javascript' | 'python' | 'bash' | 'go' | 'json',
  useDark?: boolean,
}>(), {
  useDark: true,
});

// Reactive Data

// Functions

function copyToClipboard(text: string) {
  navigator.clipboard.writeText(text)
}

// Watchers and Lifecycle Hooks

</script>

<template>
  <div class="w-full rounded-2 overflow-x-auto overflow-y-scroll">
    <div :class="[
      'p-3 md:p-4',
      useDark ? 'bg-[var(--bg-color-dark)]' : 'bg-[var(--bg-color)]'
    ]">
      <NCode
        :hljs="hljs"
        :code="code"
        :language="language"
        show-line-numbers
        word-wrap
      />
    </div>
  </div>
</template>
