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
  <template v-if="loading">
    <slot name="loading">
      <NSkeleton
        animate
        text
        :repeat="6"
      />
    </slot>
  </template>
  <NEmpty
    v-else-if="isEmpty"
    :description="emptyText"
    class="my-6"
  />
  <slot v-else />
</template>
