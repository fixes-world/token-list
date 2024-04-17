<script setup lang="ts">
import { ref, computed, inject, onMounted } from 'vue';
import { NInput } from 'naive-ui'
import type { TokenStatus } from '@shared/flow/entities';

import VueWrapper from '@components/partials/VueWrapper.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import ElementAddressBrowserLink from '@components/items/cardElements/ElementAddressBrowserLink.vue';


onMounted(() => {
  // TODO
});

</script>

<template>
  <VueWrapper>
    <div :class="['relative mx-a max-w-xl',
      'flex flex-col items-center justify-center gap-4 md:gap-6',
      'w-full sm:w-[90%] md:w-[80%] lg:w-[70%] xl:w-[60%]',
    ]">
      List
    </div>
  </VueWrapper>
</template>
