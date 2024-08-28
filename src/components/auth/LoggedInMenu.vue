<script setup lang="ts">
import { ref, h, inject, computed, onMounted } from 'vue'
import { navigate } from 'astro:transitions/client';
import { useEventBus, breakpointsTailwind, useBreakpoints } from '@vueuse/core'
import {
  NMenu, type MenuOption,
  useMessage,
} from 'naive-ui'
import {
  useGlobalAccount,
  useAppDrawerOpened,
  logoutKey,
} from '@components/shared'

import Aside from '@components/partials/Aside.vue'

const emits = defineEmits<{
  (e: 'logout'): void,
}>()

const message = useMessage()
const acctName = useGlobalAccount();
const logoutEventBus = useEventBus(logoutKey)
const isDrawerOpened = useAppDrawerOpened();

const menuOptions = computed(() => {
  const menu: MenuOption[] = [
    {
      label: 'Logout',
      key: 'logout',
      icon: () => h("div", {
        class: "i-carbon:logout w-5 h-5"
      }),
    },
  ]
  if (acctName.value) {
    menu.unshift({
      label: "Maintain Non-Fungible Token List",
      key: 'maintain-nftlist',
      icon: () => h("div", {
        class: "i-carbon:cube w-5 h-5"
      }),
    })

    menu.unshift({
      label: "Maintain Fungible Token List",
      key: 'maintain',
      icon: () => h("div", {
        class: "i-carbon:face-pending-filled w-5 h-5"
      }),
    })
  }
  return menu
})

async function handleUpdateValue(key: string, item: MenuOption) {
  switch (key) {
    case 'maintain':
      navigate(`/maintain`)
      isDrawerOpened.value = false
      break
    case 'maintain-nftlist':
      navigate(`/maintain-nftlist`)
      isDrawerOpened.value = false
      break
    case 'logout':
      logoutEventBus.emit({ address: acctName.value })
      emits('logout')
      isDrawerOpened.value = false
      break
  }
}

async function goHome() {
  navigate('/')
  isDrawerOpened.value = false
}

async function copyAddress() {
  try {
    await navigator.clipboard.writeText(acctName.value)
    message.success('Your Flow address copied to clipboard')
  } catch (e) {
    message.warning('Failed to copy your Flow address to clipboard')
  }
}

</script>

<template>
  <Aside>
    <template #header>
      <a
        class="title-base highlight italic text-3xl"
        @click="goHome"
      > TokenList </a>
    </template>
    <NMenu
      :options="menuOptions"
      @update:value="handleUpdateValue"
    />
    <template #footer>
      <div
        class="flex items-center gap-1 highlight cursor-pointer"
        @click="copyAddress"
      >
        <span class="i-carbon:copy w-4 h-4" />
        <span class="text-sm">{{ acctName }}</span>
      </div>
    </template>
  </Aside>
</template>
