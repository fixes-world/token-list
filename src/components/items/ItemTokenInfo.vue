<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue';
import type { StandardTokenView } from '@shared/flow/entities';

import ItemFungibleTokenStatus from '@components/items/ItemFungibleTokenStatus.vue';
import ElementAddressDisplay from '@components/items/cardElements/ElementAddressDisplay.vue';

const props = withDefaults(defineProps<{
  token: StandardTokenView,
  active?: boolean,
}>(), {
  active: false
});

const emits = defineEmits<{
  (e: 'select', v: StandardTokenView): void
}>()

function onClick() {
  emits('select', props.token)
}

</script>

<template>
  <div
    :class="['flex flex-col items-start gap-1',
      'px-3 py-2 rounded-lg cursor-pointer', !props.active
        ? 'bg-[var(--bg-color-dark)]'
        : 'bg-[var(--bg-color-active)]'
    ]"
    @click="onClick"
  >
    <div class="text-xs text-gray-400 italic font-semibold">
      <ElementAddressDisplay
        :address="token.identity.address"
        :short="false"
      />
    </div>
    <ItemFungibleTokenStatus :item="token.identity" />
  </div>
</template>
