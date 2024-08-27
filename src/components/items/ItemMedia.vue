<script setup lang="ts">
import type { Media } from '@shared/flow/entities';
import { NImage } from 'naive-ui';

const props = withDefaults(defineProps<{
  media?: Media,
  alt?: string,
  objectFit?: 'fill' | 'contain' | 'cover' | 'none' | 'scale-down',
  width?: number | string
}>(), {
  media: undefined,
  alt: 'Image Alt',
  objectFit: 'cover',
  width: 48
})

</script>

<template>
  <NImage
    v-if="props.media"
    :alt="props.alt"
    :width="width"
    :src="props.media.uri"
    :object-fit="objectFit"
  >
    <template #placeholder>
      <span class="mx-a i-carbon:image w-6 h-6 text-gray-400/50"/>
    </template>
  </NImage>
</template>
