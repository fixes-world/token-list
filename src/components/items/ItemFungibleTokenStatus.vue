<script setup lang="ts">
import { computed, h, ref, inject, onMounted, watch, type VNodeChild } from 'vue';
import { NTag } from 'naive-ui';
import type { TokenStatus } from '@shared/flow/entities';

const props = defineProps<{
  item?: TokenStatus;
}>();

</script>

<template>
  <div
    v-if="item !== undefined"
    class="flex items-center gap-2"
  >
    <span :class="[
      'w-5 h-5',
      item.isRegistered ? 'i-carbon:checkmark-filled highlight' : 'i-carbon:radio-button text-gray-400 opacity-60'
    ]" />
    <div class="relative inline-flex flex-wrap items-center gap-1">
      <span :class="['title-base text-sm', item.isRegistered ? 'highlight' : 'text-[var(--base-color)]']">
        {{ item.contractName }}
      </span>
      <NTag
        v-if="item.isRegistered"
        size="tiny"
        type="success"
        round
      >
        <span class="px-1">Registered</span>
      </NTag>
      <NTag
        size="tiny"
        round
        :type="item.isWithDisplay ? 'success' : 'default'"
        :bordered="!item.isWithDisplay ? false : true"
        :disabled="!item.isWithDisplay"
      >
        <span :class="['px-1', { 'decoration-line-through': !item.isWithDisplay }]">
          Display
        </span>
      </NTag>
      <NTag
        size="tiny"
        round
        :type="item.isWithVaultData ? 'warning' : 'default'"
        :bordered="!item.isWithVaultData ? false : true"
        :disabled="!item.isWithVaultData"
      >
        <span :class="['px-1', { 'decoration-line-through': !item.isWithVaultData }]">
          Vault Info
        </span>
      </NTag>
    </div>
  </div>
  <span v-else />
</template>
