<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue';
import type { StandardTokenView } from '@shared/flow/entities';

import ElementAddressDisplay from '@components/items/cardElements/ElementAddressDisplay.vue';
import ItemNativeAssetStatus from '@components/items/ItemNativeAssetStatus.vue';
import ItemTokenIcon from '@components/items/ItemTokenIcon.vue';
import TokenTag from '@components/items/tags/TokenTag.vue';

const props = withDefaults(defineProps<{
  token: StandardTokenView,
  active?: boolean,
  hoverable?: boolean,
  withDisplay?: boolean
}>(), {
  active: false,
  hoverable: true,
  withDisplay: false
});

const emits = defineEmits<{
  (e: 'select', v: StandardTokenView): void
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
      'px-4 py-3 rounded-lg',
      props.hoverable ? 'cursor-pointer' : '',
      !props.active
        ? 'bg-[var(--bg-color-dark)]'
        : 'bg-[var(--bg-color-active)]'
    ]"
    @click="onClick"
  >
    <div class="flex-auto flex flex-col items-start gap-1">
      <div class="text-xs text-gray-400 italic font-semibold flex items-center gap-1">
        <ElementAddressDisplay
          :address="token.identity.address"
          :short="false"
        />
        <div
          v-if="token.evmAddress"
          :class="['inline-block truncate', withDisplay ? 'max-w-40' : 'max-w-16']"
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
      class="flex-none flex items-center items-end gap-2 md:gap-4"
    >
      <span class="title-base highlight text-2xl">
        ${{ token.display?.display?.symbol }}
      </span>
      <ItemTokenIcon
        :token="token"
        :width="40"
      />
    </div>
  </div>
</template>
