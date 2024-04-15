<script setup lang="ts">
import { ref, computed } from 'vue'
import {
  NSkeleton, NEmpty,
} from 'naive-ui';
import { queryTokenList } from '@shared/flow/action/scripts';
import { FlowSrvKey } from '@shared/flow/utilitites';
import type { TokenIdentity } from '@shared/flow/entities';

const props = withDefaults(defineProps<{
  ft?: TokenIdentity
}>(), {
  ft: undefined
})

const emits = defineEmits<{
  (e: 'update:ft', v: TokenIdentity | undefined): void
}>()

const isLoading = ref(false)
const current = computed({
  get: () => props.ft,
  set: (v?: TokenIdentity) => {
    emits('update:ft', v)
  }
})

</script>

<template>
  <div class="min-w-[12rem]">List</div>
</template>
