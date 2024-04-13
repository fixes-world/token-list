<script setup lang="ts">
import { ref, h, inject, computed } from 'vue'
import { navigate } from 'astro:transitions/client';
import { useEventBus, breakpointsTailwind, useBreakpoints } from '@vueuse/core'
import {
  NDropdown,
  type DropdownDividerOption, type DropdownOption,
  useMessage,
} from 'naive-ui'
import {
  useGlobalAccount,
} from '@components/shared'

import { FlowSrvKey } from "@shared/flow/utilitites";

import UserAddressWithAvatar from '@components/auth/UserAddressWithAvatar.vue'

const emits = defineEmits<{
  (e: 'logout'): void,
  (e: 'refresh'): void,
}>()

const message = useMessage()
const acctName = useGlobalAccount();

const breakpoints = useBreakpoints(breakpointsTailwind)
const isWithAside = breakpoints.greaterOrEqual('md')

const showCreateEntrustedAccountModal = ref(false)

type DropdownMixedOption = DropdownOption | DropdownDividerOption

const dropdownOptions = computed(() => {
  const options: DropdownMixedOption[] = [
    {
      label: 'Logout',
      key: 'logout',
      icon: () => h("div", {
        class: "i-carbon:logout w-5 h-5"
      }),
    },
  ]
  if (acctName.value) {
    options.unshift({
      label: "Maintain",
      key: 'maintain',
      icon: () => h("div", {
        class: "i-carbon:face-pending-filled w-5 h-5"
      }),
    })
  }
  return options
})

async function handleDropdownCommand(command: string) {
  switch (command) {
    case 'profile':
      navigate(`/address/${acctName?.value}`)
      break
    case 'transfer':
      navigate(`/transfer`)
      break
    case 'logout':
      emits('logout')
      break
    case 'flow-address':
      try {
        await navigator.clipboard.writeText(acctName.value)
        message.success('Your Entrusted Flow address copied to clipboard')
      } catch (e) {
        message.warning('Failed to copy your Flow address to clipboard')
      }
      break
  }
}

async function reloadEVMEntrustedAccount() {
  emits('refresh')
}

// Watchers and lifecycle

</script>

<template>
  <NDropdown
    :options="dropdownOptions"
    trigger="click"
    size="huge"
    placement="top-start"
    animated
    show-arrow
    @select="handleDropdownCommand"
  >
    <UserAddressWithAvatar
      :short="isWithAside"
      :is-aside="false"
    />
  </NDropdown>
</template>
