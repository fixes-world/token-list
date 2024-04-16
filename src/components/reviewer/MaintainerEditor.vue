<script setup lang="ts">
import { ref, computed, inject, watch } from 'vue'
import {
  NSkeleton, NEmpty,
} from 'naive-ui';

import { getAddressReviewerStatus } from '@shared/flow/action/scripts';
import { FlowSrvKey } from '@shared/flow/utilitites';
import type { StandardTokenView, AddressStatus } from '@shared/flow/entities';
import { useGlobalAccount } from '@components/shared';

import VueWrapper from '@components/partials/VueWrapper.vue';
import EnsureConnected from '@components/flow/EnsureConnected.vue';
import FormSubmitClaimMaintainer from '@components/reviewer/form/FormSubmitClaimMaintainer.vue';
import FormSubmitInitReviewer from '@components/reviewer/form/FormSubmitInitReviewer.vue';
import PanelTokenList from '@components/reviewer/panel/PanelTokenList.vue';
import PanelTokenEditor from '@components/reviewer/panel/PanelTokenEditor.vue';

const flowSrv = inject(FlowSrvKey);
const acctName = useGlobalAccount();

// Reactive Variables

const addrStatus = ref<AddressStatus | null>(null);

const isFirstLoading = ref(false)

const currentToken = ref<StandardTokenView | undefined>(undefined)

const isEditorAvailable = computed(() => {
  return addrStatus.value && (addrStatus.value.isReviewer || addrStatus.value.isReviewMaintainer)
})
const isMaintainerClaimable = computed(() => {
  return addrStatus.value && addrStatus.value.isPendingToClaimReviewMaintainer && addrStatus.value.reviewerAddr
})
const isPlaceCenter = computed(() => {
  return !addrStatus.value || isMaintainerClaimable.value || !isEditorAvailable.value
})

// Functions

async function loadAddrStatus() {
  if (!flowSrv || !acctName.value) return
  addrStatus.value = await getAddressReviewerStatus(flowSrv, acctName.value)
}

async function refresh() {
  addrStatus.value = null

  isFirstLoading.value = true
  await loadAddrStatus()
  isFirstLoading.value = false
}

// Watchers and Lifecycle Hooks

watch(acctName, refresh, { immediate: true })

</script>

<template>
  <VueWrapper>
    <div :class="['min-h-[calc(100vh-36rem)] flex', isPlaceCenter ? 'items-center justify-center' : '']">
      <EnsureConnected type="primary">
        <template #not-connected>
          <span class="text-lg">Connect wallet to access Maintainer Editor</span>
        </template>
        <NSkeleton
          v-if="isFirstLoading"
          animate
          text
          :repeat="6"
        />
        <NEmpty
          v-else-if="!addrStatus"
          description="Failed to load address status"
          class="my-6"
        />
        <template v-else>
          <div
            v-if="isEditorAvailable"
            class="w-full flex items-start justify-between gap-4"
          >
            <PanelTokenList
              class="flex-none"
              v-model:ft="currentToken"
            />
            <div class="flex-auto">
              <p
                v-if="!currentToken"
                class="mx-a my-10 italic text-gray-400/60 text-xl font-semibold text-center"
              >
                Select a fungible token to edit
              </p>
              <PanelTokenEditor :ft="currentToken" />
            </div>
          </div>
          <div
            v-else
            class="flex flex-col gap-6 items-center justify-start"
          >
            <h2 class="text-lg">
              <span v-if="isMaintainerClaimable">You can claim as a Maintainer for {{ addrStatus.reviewerAddr }}</span>
              <span>You can ask any <strong>Reviewer</strong> to set you as a <strong>Maintainer</strong></span>
            </h2>
            <FormSubmitClaimMaintainer
              :reviewer="addrStatus.reviewerAddr"
              @success="refresh"
            />
            <h2 class="text-lg"> or </h2>
            <FormSubmitInitReviewer @success="refresh" />
          </div>
        </template>
      </EnsureConnected>
    </div>
  </VueWrapper>
</template>
