<script setup lang="ts">
import { inject } from 'vue';
import appInfo from '@shared/config/info';

import ElementAddressDisplay from '@components/items/cardElements/ElementAddressDisplay.vue';

withDefaults(defineProps<{
  address: string,
  short?: boolean,
  // notResolve?: boolean
}>(), {
  short: true,
  // notResolve: true,
})

function getAccountURL(addr: string) {
  const host = appInfo.network === 'testnet'
    ? "https://testnet.flowdiver.io/account/"
    : "https://www.flowdiver.io/account/"
  return host + addr;
}
</script>

<template>
  <a
    class="inline-flex items-center gap-1"
    :href="getAccountURL(address)"
    target="_blank"
  >
    <slot name="icon">
      <span class="i-carbon:wallet w-4 h-4" />
    </slot>
    <ElementAddressDisplay
      :address="address"
      :short="short"
    />
  </a>
</template>
