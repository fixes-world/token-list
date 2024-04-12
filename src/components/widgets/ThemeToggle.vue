<script setup lang="ts">
import { watch, ref } from 'vue'
import { useToggle } from '@vueuse/core';
import { useSharedDark } from '@components/shared';

// import VueWrapper from '@components/partials/VueWrapper.vue';

const isDark = useSharedDark()
const toggleDark = useToggle(isDark)

</script>

<template>
  <div class="cursor-pointer focus:outline-none" @click="toggleDark()">
    <span class="sr-only">View ThemeToggle</span>
    <span :class="['w-8 h-8', isDark ? 'i-carbon:sun' : 'i-carbon:moon']" />
  </div>
</template>
