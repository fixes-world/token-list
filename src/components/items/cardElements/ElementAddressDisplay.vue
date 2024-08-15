<script setup lang="ts">
import { computed, ref, inject, watch } from 'vue';
import appInfo from '@shared/config/info';
import { useSharedAddressNamingCache } from '@components/shared';
import { resolveAddressName } from '@shared/flow/action/scripts';

const props = withDefaults(defineProps<{
  address?: string,
  short?: boolean,
  notResolve?: boolean,
}>(), {
  short: false,
  notResolve: false,
});

const namingCache = useSharedAddressNamingCache()

const addressDisplay = computed(() => {
  if (props.address === appInfo.contractAddr) {
    return "Official Team"
  }
  const displayName = (resolvedName.value || props.address) ?? ""
  const sliceMax = props.short ? 10 : 20
  return displayName.length <= sliceMax ? displayName : displayName.slice(0, sliceMax) + '..'
});

const resolvedName = ref<string | null>(null)

async function resolveAddress(address: string) {
  if (address !== appInfo.contractAddr && !props.notResolve) {
    if (typeof namingCache[address] === 'string') {
      resolvedName.value = namingCache[address]
      return
    }
    const resolved = await resolveAddressName(address)
    if (resolved && typeof resolved === 'string') {
      namingCache[address] = resolved
    }
    resolvedName.value = resolved
  }
}

watch(() => props.address, async (address) => {
  if (address) {
    await resolveAddress(address)
  }
}, { immediate: true })
</script>

<template>
  <span class="text-center truncate">
  {{ addressDisplay }}
</span>
</template>
