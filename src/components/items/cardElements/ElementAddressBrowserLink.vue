<script setup lang="ts">
import { computed, inject } from 'vue';
import appInfo from '@shared/config/info';

import ElementAddressDisplay from '@components/items/cardElements/ElementAddressDisplay.vue';

const props = withDefaults(defineProps<{
  address: string,
  short?: boolean,
  // notResolve?: boolean
}>(), {
  short: true,
  // notResolve: true,
})

const isEVMAddress = computed(() => props.address && /0x[a-fA-F0-9]{40}/ig.test(props.address))

function getAccountURL(addr: string) {
  const host = appInfo.network === 'testnet'
    ? (!isEVMAddress.value ? "https://testnet.flowscan.io/account/" : "https://evm-testnet.flowscan.io/address/")
    : (!isEVMAddress.value ? "https://www.flowdiver.io/account/" : "https://evm.flowscan.io/address/");
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
