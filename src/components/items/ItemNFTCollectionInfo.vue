<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue';
import type { StandardNFTCollectionView } from '@shared/flow/entities';

import ElementAddressDisplay from '@components/items/cardElements/ElementAddressDisplay.vue';
import ItemNativeAssetStatus from '@components/items/ItemNativeAssetStatus.vue';
import TokenTag from '@components/items/tags/TokenTag.vue';
import ItemMedia from '@components/items/ItemMedia.vue';

const props = withDefaults(defineProps<{
  token: StandardNFTCollectionView,
  active?: boolean,
  hoverable?: boolean,
  withDisplay?: boolean
}>(), {
  active: false,
  hoverable: true,
  withDisplay: false
});

const emits = defineEmits<{
  (e: 'select', v: StandardNFTCollectionView): void
}>()

function onClick() {
  if (!props.hoverable) return;
  emits('select', props.token)
}

</script>

<template>
  <div
    :class="[
      'flex items-center justify-between gap-2',
      'relative px-4 py-3 rounded-lg',
      props.hoverable ? 'cursor-pointer' : '',
      !props.active
        ? 'border border-dashed hover:border-solid border-[var(--primary-color)] bg-[var(--bg-color-dark)]'
        : 'border border-solid border-[var(--primary-hover-color)] bg-[var(--bg-color-active)]'
    ]"
    @click="onClick"
  >
    <div class="z-0 absolute left-0 top-0 w-full h-full">
      <ItemMedia
        class="w-full h-full rounded-lg opacity-10"
        :media="token.display?.display?.bannerImage"
        :alt="`Banner Image for ${token.display?.display?.name}`"
        width="100%"
      />
    </div>
    <div class="z-10 flex-auto flex flex-col items-start gap-1">
      <div class="text-xs text-gray-400 italic font-semibold flex items-center gap-1">
        <ElementAddressDisplay
          :address="token.identity.address"
          :short="false"
        />
        <div
          v-if="token.evmAddress"
          class="inline-block max-w-40 truncate"
        >
          / {{ token.evmAddress }}
        </div>
      </div>
      <div class="flex flex-wrap items-center gap-1">
        <ItemNativeAssetStatus :item="token.identity" />
        <template v-if="token.tags.length > 0">
          <TokenTag
            v-for="tag in token.tags"
            :key="tag"
            :tag="tag"
          />
        </template>
      </div>
    </div>
    <div
      v-if="withDisplay && token.display?.display"
      class="z-10 flex-none flex items-center items-end gap-2 md:gap-4"
    >
      <div class="title-base highlight text-xl truncate px-1 max-w-64">
        {{ token.display?.display?.name }}
      </div>
      <ItemMedia
        :alt="`Square Image for ${token.display?.display?.name}`"
        :media="token.display.display.squareImage"
      />
    </div>
  </div>
</template>
