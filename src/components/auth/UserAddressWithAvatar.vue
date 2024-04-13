<script setup lang="ts">
import { computed } from 'vue';
import { NAvatar, NTag, useThemeVars } from 'naive-ui'
import { useCurrentSignerAddress, useGlobalAccount, useIsConnected } from '@components/shared';

import FlowLogo from '@assets/flow.svg?component';
import ElementAddressDisplay from '@components/items/cardElements/ElementAddressDisplay.vue';

withDefaults(defineProps<{
  short?: boolean;
  isAside?: boolean;
}>(), {
  short: true,
  isAside: false,
})

const themeVars = useThemeVars();
const isConnected = useIsConnected();
const currentUserAddr = useCurrentSignerAddress();

const avatarUrl = computed(() => {
  if (typeof currentUserAddr.value === 'string') {
    const addr = currentUserAddr.value
    const colors = [
      themeVars.value.primaryColor,
      themeVars.value.primaryColorHover,
      themeVars.value.successColor,
      themeVars.value.warningColor,
      themeVars.value.errorColor,
    ]
    return `https://source.boringavatars.com/beam/40/${addr}?colors=${colors.map(o => o.replace("#", "")).join(',')}`
  } else {
    return undefined
  }
})

</script>

<template>
  <div :class="[
    'relative w-full flex items-center gap-2',
    isAside
      ? 'justify-start pl-3 md:(pl-0 justify-center) group-hover:md:(pl-4 justify-start)'
      : '',
  ]">
    <div class="relative flex-none w-fit flex items-center">
      <n-avatar
        round
        size="medium"
        :src="avatarUrl"
      />
      <div
        v-if="!isConnected"
        :class="[
        'flex justify-between',
        'absolute -bottom-1 -left-2 z-20',
]"
      >
        <div>
          <FlowLogo :class="['h-4 w-4']" />
        </div>
      </div>
    </div>
    <div :class="[
      'flex items-center justify-between gap-1',
      'hover:text-[var(--primary-color)] text-lg',
      'transition-opacity duration-100',
      isAside
        ? 'absolute pl-9 opacity-100 md:(invisible opacity-0) group-hover:md:(visible opacity-100 delay-150 duration-500)'
        : 'relative',
    ]">
      <div class="relative flex-auto flex flex-col items-start">
        <ElementAddressDisplay
          :address="currentUserAddr"
          :short="short"
          class="font-semibold"
        />
        <NTag
          type="primary"
          size="tiny"
          round
          class="-ml-1"
        >
          <div class="text-center text-xs px-1">
            <span>Flow Native</span>
          </div>
        </NTag>
      </div>
      <span class="i-carbon:caret-right w-4 h-4 flex-none" />
    </div>
  </div>
</template>
