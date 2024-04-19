<script setup lang="ts">
import { ref, computed, reactive, onMounted, inject } from 'vue';
import { NTag } from 'naive-ui';
import ItemHintLabel from '../ItemHintLabel.vue';

const props = defineProps<{
  tag: string,
}>();

const isPending = computed(() => {
  return props.tag === 'Pending';
});

const isVerified = computed(() => {
  return props.tag === 'Verified';
});

const isFeatured = computed(() => {
  return props.tag === 'Featured';
});

const isSystemTag = computed(() => {
  return isPending.value || isVerified.value || isFeatured.value;
});

</script>

<template>
  <NTag
    size="tiny"
    round
    :type="isFeatured ? 'warning' : isVerified ? 'success' : isPending ? 'default' : 'info'"
    :bordered="false"
  >
    <ItemHintLabel
      v-if="isSystemTag"
      :with-warning-icon="false"
    >
      <span v-if="isPending" class="i-carbon:radar w-3 h-3" />
      <span v-else-if="isFeatured" class="i-carbon:star-filled w-3 h-3" />
      <span v-else-if="isVerified" class="i-carbon:checkmark-filled w-3 h-3" />
      <template #hint>
        {{ tag }}
      </template>
    </ItemHintLabel>
    <span v-else>{{ tag }}</span>
  </NTag>
</template>
