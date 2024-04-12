<script setup lang="ts">
import FlowLogoWhite from '@assets/flow-white.svg?component';
import FlowConnectButton from '@components/flow/FlowConnectButton.vue'

</script>

<template>
  <FlowConnectButton size="large" class="relative group">
    <template #icon>
      <FlowLogoWhite class="h-6 w-6" />
    </template>
    <div class="w-0 group-hover:w-15 transition-all duration-200 ease-out">
    </div>
    <span :class="[
      'absolute w-fit text-sm font-semibold',
      'transition-all duration-200 ease-out',
      'invisible opacity-0',
      'group-hover:(visible opacity-100 delay-100 duration-300)',
    ]">
      Connect
    </span>
  </FlowConnectButton>
</template>
