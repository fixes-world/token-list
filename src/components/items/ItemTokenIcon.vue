<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue';
import type { StandardTokenView } from '@shared/flow/entities';
import { NImage } from 'naive-ui';

const props = withDefaults(defineProps<{
  token: StandardTokenView,
  width?: number | string
}>(), {
  width: 48
})

const firstIconUrl = computed(() => {
  return props.token.display?.display?.logos?.[0]?.uri
})

</script>

<template>
  <NImage
    :alt="`Token Icon: ${token.identity.address}.${token.identity.contractName}`"
    :width="width"
    :src="firstIconUrl"
  >
    <template #placeholder>
      <span class="mx-a i-carbon:image w-6 h-6 text-gray-400/50"/>
    </template>
  </NImage>
</template>
