<script setup lang="ts">
import type { ReviewerInfo } from '@shared/flow/entities';
import { NTag } from 'naive-ui';

import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import ElementAddressDisplay from '@components/items/cardElements/ElementAddressDisplay.vue';

const props = defineProps<{
  current: ReviewerInfo;
}>()

</script>

<template>
  <div class="w-full flex items-center justify-between gap-2">
    <ElementWrapper
      direction="row"
      :title="current?.name ?? 'Address'"
    >
      <div class="inline-flex items-center gap-2 text-xs font-semibold">
        <a
          :href="current.url"
          target="_blank"
        >
          <ElementAddressDisplay
            :address="current?.address"
            :short="false"
          />
        </a>
      </div>
    </ElementWrapper>
    <NTag
      v-if="current.verified"
      type="success"
      size="tiny"
      round
      :bordered="false"
    >
      <template #icon>
        <span class="i-carbon:checkmark-filled w-3 h-3"/>
      </template>
      Verified
    </NTag>
  </div>
</template>
