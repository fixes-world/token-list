<script setup lang="ts">
import { computed, h, ref, inject, onMounted, watch, type VNodeChild } from 'vue';
import type { TokenStatus } from '@shared/flow/entities';

const props = defineProps<{
  item?: TokenStatus;
}>();

</script>

<template>
  <div
    v-if="item !== undefined"
    class="flex flex-wrap items-center gap-2"
  >
    <span :class="[
      'w-5 h-5',
      item.isRegistered ? 'i-carbon:checkmark-filled highlight' : 'i-carbon:radio-button text-gray-400 opacity-60'
    ]" />
    <div class="inline-flex flex-wrap gap-2">
      <span>{{ item.contractName }}</span>
    </div>
  </div>
  <span v-else />
</template>
