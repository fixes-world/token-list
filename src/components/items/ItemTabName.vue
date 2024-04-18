<script setup lang="ts">
const props = defineProps<{
  label: string,
}>()
</script>

<template>
  <div class="inline-flex items-center">
    <div class="px-4 lg:px-2">
      <slot name="icon">
        <span class="i-carbon:application w-5 h-5" />
      </slot>
    </div>
    <span class="hidden lg:inline lg:pr-2">
    <slot>{{ label }}</slot>
  </span>
  </div>
</template>
