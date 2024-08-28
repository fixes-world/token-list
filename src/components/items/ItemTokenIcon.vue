<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue';
import type { StandardTokenView } from '@shared/flow/entities';

import ItemMedia from '@components/items/ItemMedia.vue';

const props = withDefaults(defineProps<{
  token: StandardTokenView,
  width?: number | string
}>(), {
  width: 48
})

const firstIcon = computed(() => {
  return props.token.display?.display?.logos?.[0]!
})

</script>

<template>
  <ItemMedia
    :media="firstIcon"
    :alt="`Token Icon: ${token.identity.address}.${token.identity.contractName}`"
    :width="width"
  />
</template>
