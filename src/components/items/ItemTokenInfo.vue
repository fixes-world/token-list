<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue';
import type { StandardTokenView } from '@shared/flow/entities';

import ElementAddressDisplay from '@components/items/cardElements/ElementAddressDisplay.vue';
import ItemFungibleTokenStatus from '@components/items/ItemFungibleTokenStatus.vue';
import ItemTokenIcon from '@components/items/ItemTokenIcon.vue';

const props = withDefaults(defineProps<{
  token: StandardTokenView,
  active?: boolean,
  hoverable?: boolean,
  withIcon?: boolean
}>(), {
  active: false,
  hoverable: true,
  withIcon: false
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
      'flex flex-wrap items-center justify-between gap-2',
      'px-4 py-3 rounded-lg',
      props.hoverable ? 'cursor-pointer' : '',
      !props.active
        ? 'bg-[var(--bg-color-dark)]'
        : 'bg-[var(--bg-color-active)]'
    ]"
    @click="onClick"
  >
    <div class="flex flex-col items-start gap-1">
      <div class="text-xs text-gray-400 italic font-semibold">
        <ElementAddressDisplay
          :address="token.identity.address"
          :short="false"
        />
      </div>
      <ItemFungibleTokenStatus :item="token.identity" />
    </div>
    <ItemTokenIcon
      v-if="withIcon"
      :token="token"
      :width="40"
    />
  </div>
</template>
