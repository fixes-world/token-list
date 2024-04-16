<script setup lang="ts">
import { ref, computed, inject } from 'vue'
import { NSkeleton, NEmpty } from 'naive-ui';
import type { StandardTokenView } from '@shared/flow/entities';

const props = withDefaults(defineProps<{
  ft?: StandardTokenView,
}>(), {
  ft: undefined,
})
</script>

<template>
  <div>
    {{ ft }}
  </div>
</template>
