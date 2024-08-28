<script setup lang="ts">
import { NSkeleton, NEmpty } from 'naive-ui';

const props = withDefaults(defineProps<{
  loading?: boolean,
  isEmpty?: boolean,
  emptyText?: string,
}>(), {
  loading: false,
  isEmpty: false,
  emptyText: "No data",
})

</script>

<template>
  <NSkeleton
    v-if="loading"
    animate
    text
    :repeat="6"
  />
  <NEmpty
    v-else-if="isEmpty"
    :description="emptyText"
    class="my-6"
  />
  <slot v-else />
</template>
