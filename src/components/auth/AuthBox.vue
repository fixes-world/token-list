<script setup lang="ts">
import { ref, h, inject, computed, watch } from 'vue'
import { useEventBus } from '@vueuse/core'
import {
  useCurrentFlowUser,
  useNetworkCorrect,
  updateGlobalAccount,
  useIsConnected,
  logoutKey,
} from '@components/shared'

import { FlowSrvKey } from "@shared/flow/utilitites";

import VueWrapper from '@components/partials/VueWrapper.vue'
import AuthBoxNotLoggedIn from '@components/auth/AuthBoxNotLoggedIn.vue'
import AuthBoxLoggedIn from '@components/auth/AuthBoxLoggedIn.vue'
import LoggedInMenu from '@components/auth/LoggedInMenu.vue'

const flowSrv = inject(FlowSrvKey);
const isNetworkCorrect = useNetworkCorrect();
const currentFlowUser = useCurrentFlowUser();
const isLoggedIn = useIsConnected();
const logoutEventBus = useEventBus(logoutKey)

function logout() {
  if (!!currentFlowUser.value) {
    // Flow Wallet logout
    flowSrv?.unauthenticate();
  }
}

watch(currentFlowUser, (user) => {
  updateGlobalAccount(user?.addr)
})

logoutEventBus.on(() => {
  logout()
})

// subscribe to user for header
flowSrv?.currentUser.subscribe((user) => {
  if (user && user.addr) {
    currentFlowUser.value = user;
    const accountProof = user.services?.find(one => one.type === "account-proof")
    const uid = accountProof?.uid
    if (accountProof && uid && (uid.indexOf("lilico") >= 0 || uid.indexOf("frw") >= 0 || uid.indexOf("fcw") >= 0)) {
      isNetworkCorrect.value = accountProof?.network === flowSrv?.network
    } else {
      isNetworkCorrect.value = true
    }
    console.log(`Flow User loggedIn: ${user.addr}, network: ${accountProof?.network}, correct: ${isNetworkCorrect.value}`);
    console.log(`Proof: ${JSON.stringify(accountProof?.data)}`)
  } else {
    currentFlowUser.value = null;
    isNetworkCorrect.value = false
    console.log('Flow User loggedOut')
  }
});
</script>

<template>
  <VueWrapper
    :class="[
    'flex flex-col items-center', !isLoggedIn ? 'gap-2' : 'gap-0',
]"
    :is-global="true"
  >
    <AuthBoxNotLoggedIn v-if="!isLoggedIn" />
    <template v-else>
      <AuthBoxLoggedIn />
      <LoggedInMenu />
    </template>
  </VueWrapper>
</template>
