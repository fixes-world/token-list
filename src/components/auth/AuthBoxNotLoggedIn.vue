<script setup lang="ts">
// import FlowLogoWhite from '@assets/flow-white.svg?component';
import FlowConnectButton from '@components/flow/FlowConnectButton.vue'

</script>

<template>
  <FlowConnectButton
    size="large"
    class="relative group"
  >
    <template #icon>
      <span class="i-carbon:wallet h-5 w-5" />
    </template>
    <div class="w-0 group-hover:w-15 transition-all duration-200 ease-out truncate">
      <span :class="[
        'text-sm font-semibold',
        'invisible opacity-0',
        'group-hover:(visible opacity-100 duration-300)',
      ]">
        Connect
      </span>
    </div>
  </FlowConnectButton>
</template>
