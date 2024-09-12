<script setup lang="ts">
import { computed, h, ref, inject, onMounted, watch, type VNodeChild } from 'vue';
import { NTag } from 'naive-ui';
import type { EVMAssetStatus } from '@shared/flow/entities';

import ItemHintLabel from "@components/items/ItemHintLabel.vue";

const props = defineProps<{
  item?: EVMAssetStatus;
}>();

const isHighlight = computed(() => props.item?.isRegistered);

</script>

<template>
  <div
    v-if="item !== undefined"
    class="flex items-center gap-2"
  >
    <span
      v-if="typeof item.isRegistered === 'boolean'"
       :class="[
        'w-5 h-5',
        item.isRegistered ? 'i-carbon:checkmark-filled highlight' : 'i-carbon:radio-button text-gray-400 opacity-60'
      ]" />
    <div class="relative inline-flex flex-wrap items-center gap-1">
      <span :class="['w-fit title-base text-sm', isHighlight ? 'highlight' : 'text-[var(--base-color)]']">
        {{ item.isRegistered ? 'Registered' : 'Not Registered' }}
      </span>
      <NTag
        size="tiny"
        type="info"
        round
      >
        <span class="px-1">{{ item.isNFT ? "ERC721" : "ERC20" }}</span>
      </NTag>
      <NTag
        v-if="item.isBridged"
        size="tiny"
        type="warning"
        round
      >
        <span class="px-1">Bridged</span>
      </NTag>
      <div
        v-if="item.isBridged"
        :class="['w-fit space-x-1', isHighlight ? 'highlight' : 'text-[var(--base-color)]']"
      >
        <span class="title-base">{{ `${item.bridgedType?.contractName}` }}</span>
        <span class="text-sm opacity-70">{{ `@${item.bridgedType?.address}` }}</span>
      </div>
    </div>
  </div>
  <span v-else />
</template>
