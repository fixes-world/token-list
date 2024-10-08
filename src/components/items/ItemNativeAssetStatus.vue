<script setup lang="ts">
import { computed, h, ref, inject, onMounted, watch, type VNodeChild } from 'vue';
import { NTag } from 'naive-ui';
import type { TokenStatusBasic } from '@shared/flow/entities';

import ItemHintLabel from "@components/items/ItemHintLabel.vue";

const props = defineProps<{
  item?: TokenStatusBasic;
}>();

const isHighlight = computed(() => {
  if (typeof props.item?.isRegistered === 'boolean') {
    return props.item?.isRegistered;
  }
  return props.item?.isWithDisplay && props.item?.isWithVaultData;
});

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
      <span :class="['w-fit max-w-xs title-base text-sm truncate', isHighlight ? 'highlight' : 'text-[var(--base-color)]']">
        {{ item.contractName }}
      </span>
      <NTag
        size="tiny"
        :type="item?.isNFT ? 'info' : 'primary'"
        round
      >
        <span class="px-1">{{ item.isNFT ? 'NFT' : "FT" }}</span>
      </NTag>
      <NTag
        v-if="item.isBridged"
        size="tiny"
        type="warning"
        round
      >
        <span class="px-1">Bridged</span>
      </NTag>
      <ItemHintLabel :with-warning-icon="false">
        <NTag
          class="pointer-events-none"
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
        <template #hint>
          <p class="text-xs">
            <span v-if="!item.isWithDisplay">The display data is not found.</span>
            <span v-else>The display data is available.</span>
          </p>
        </template>
      </ItemHintLabel>
      <ItemHintLabel
        v-if=!item.isWithVaultData
        :with-warning-icon="false"
      >
        <NTag
          class="pointer-events-none"
          size="tiny"
          round
          type="default"
          bordered
          disabled
        >
          <span :class="['px-1', { 'decoration-line-through': !item.isWithVaultData }]">
            Vault Info
          </span>
        </NTag>
        <template #hint>
          <p class="text-xs">
            <span v-if="!item.isWithVaultData">The vault data is not found.</span>
            <span v-else>The vault data is available.</span>
          </p>
        </template>
      </ItemHintLabel>
    </div>
  </div>
  <span v-else />
</template>
