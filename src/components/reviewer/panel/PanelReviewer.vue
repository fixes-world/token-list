<script setup lang="ts">
import { ref, computed, inject, watch } from 'vue'
import {
  NSkeleton, NEmpty, NDivider,
} from 'naive-ui';
// import { getAddressReviewerStatus } from '@shared/flow/action/scripts';
import { FlowSrvKey } from '@shared/flow/utilitites';
import type { StandardTokenView, AddressStatus } from '@shared/flow/entities';
import { useGlobalAccount } from '@components/shared';

import EnsureConnected from '@components/flow/EnsureConnected.vue';
import ElementAddressBrowserLink from '@components/items/cardElements/ElementAddressBrowserLink.vue';

const props = defineProps<{
  reviewer?: string
}>();

const flowSrv = inject(FlowSrvKey);
const acctName = useGlobalAccount();

// Reactive Variables

const isFirstLoading = ref(false)

// Functions

async function loadAddrStatus() {
  if (!flowSrv) return

  // TODO
}

async function refresh() {

  isFirstLoading.value = true
  // TODO: load reviewer metadata
  isFirstLoading.value = false
}

// Watchers and Lifecycle Hooks

watch(acctName, refresh, { immediate: true })

</script>

<template>
  <div
    v-if="reviewer"
    class="inline-flex items-center gap-2 italic text-gray-400/60 font-semibold"
  >
    <h2 class="text-lg">Edit as Reviewer</h2>
    <ElementAddressBrowserLink
      :address="reviewer"
      :short="false"
    />
  </div>
</template>
