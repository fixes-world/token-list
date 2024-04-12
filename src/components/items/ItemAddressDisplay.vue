<script setup lang="ts">
import { computed, ref, inject, watch } from 'vue';

const props = withDefaults(defineProps<{
  address?: string,
  short?: boolean,
}>(), {
  address: 'No Address',
  short: false,
});

const addressDisplay = computed(() => {
  const displayName = props.address
  const sliceMax = props.short ? 10 : 20
  return displayName.length <= sliceMax ? displayName : displayName.slice(0, sliceMax) + '..'
});
</script>

<template>
  <span class="text-center truncate">
    {{ addressDisplay }}
  </span>
</template>
