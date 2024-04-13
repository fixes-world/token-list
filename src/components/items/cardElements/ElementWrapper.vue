<script setup lang="ts">
withDefaults(defineProps<{
  title?: string,
  hideTitle?: boolean,
  position?: 'left' | 'center' | 'right',
  direction?: 'col' | 'row' | 'auto',
  opacity?: boolean
}>(), {
  title: 'Title',
  hideTitle: false,
  position: 'center',
  direction: 'col',
  opacity: true,
})
</script>

<template>
  <div :class="[
    'flex',
    direction === 'col'
      ? 'flex-col gap-1'
      : direction === 'row'
        ? 'flex-row gap-2 h-full items-center'
        : 'flex-col gap-1 lg:flex-row lg:gap-2 lg:h-full lg:items-center',
  ]">
    <span
      v-if="!hideTitle"
      :class="[
        'flex-none flex-inline items-center justify-between gap-1',
        { 'opacity-60': opacity }
      ]">
      <slot name="prefix" />
      <span :class="[
        'flex-auto',
        {
          'text-left': position === 'left',
          'text-center': position === 'center',
          'text-right': position === 'right',
        }
      ]">
        <slot name="title">
          {{ title }}
        </slot>
      </span>
    <slot name="suffix" />
    </span>
    <slot />
  </div>
</template>
