<script setup lang="ts">
import { ref, computed, inject, watch } from 'vue'
import {
  NSkeleton, NEmpty, NDivider,
} from 'naive-ui';

import { getAddressReviewerStatus } from '@shared/flow/action/scripts';
import type { StandardTokenView, AddressStatus } from '@shared/flow/entities';
import { useGlobalAccount } from '@components/shared';

import VueWrapper from '@components/partials/VueWrapper.vue';
import EnsureConnected from '@components/flow/EnsureConnected.vue';
import ElementAddressBrowserLink from '@components/items/cardElements/ElementAddressBrowserLink.vue';
import FormSubmitClaimMaintainer from '@components/reviewer/form/FormSubmitClaimMaintainer.vue';
import FormSubmitInitReviewer from '@components/reviewer/form/FormSubmitInitReviewer.vue';
import PanelTokenList from '@components/reviewer/panel/PanelTokenList.vue';
import PanelReviewer from '@components/reviewer/panel/PanelReviewer.vue';
import PanelTokenEditor from '@components/reviewer/panel/PanelTokenEditor.vue';
import PanelTokenReview from '@components/reviewer/panel/PanelTokenReview.vue';

const acctName = useGlobalAccount();

// Reactive Variables

const tokenListRef = ref<typeof PanelTokenList | null>(null);

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
  return !isFirstLoading && (!addrStatus.value || isMaintainerClaimable.value || !isEditorAvailable.value)
})

// Functions

async function loadAddrStatus() {
  if (!acctName.value) return
  addrStatus.value = await getAddressReviewerStatus(acctName.value)
}

async function reloadAddrStatus() {
  addrStatus.value = null

  isFirstLoading.value = true
  await loadAddrStatus()
  isFirstLoading.value = false
}

async function refreshTokenList() {
  if (tokenListRef.value) {
    await tokenListRef.value?.reload()
  }
  currentToken.value = undefined
}

// Watchers and Lifecycle Hooks

watch(acctName, reloadAddrStatus, { immediate: true })

</script>

<template>
  <VueWrapper id="MaintainerEditor">
    <div :class="['min-h-[calc(100vh-36rem)] flex flex-col', isPlaceCenter ? 'items-center justify-center' : '']">
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
              ref="tokenListRef"
              class="flex-none"
              v-model:ft="currentToken"
              :reviewer="addrStatus.reviewerAddr"
            />
            <div class="flex-auto flex flex-col">
              <PanelReviewer :reviewer="addrStatus.reviewerAddr" />
              <p
                v-if="!currentToken"
                class="mx-a my-10 italic text-gray-400/60 text-xl font-semibold text-center"
              >
                Select a fungible token to edit
              </p>
              <template v-else>
                <NDivider class="!mt-4 !mb-6">
                  <span class="text-sm italic font-bold text-gray-400/60">Token Metadata Editor</span>
                </NDivider>
                <PanelTokenEditor
                  :ft="currentToken"
                  @refresh="refreshTokenList"
                />
                <NDivider>
                  <span class="text-sm italic font-bold text-gray-400/60">Token Review</span>
                </NDivider>
                <PanelTokenReview
                  :ft="currentToken"
                  @refresh="refreshTokenList"
                />
              </template>
            </div>
          </div>
          <div
            v-else
            class="flex flex-col gap-6 items-center justify-start"
          >
            <h2 class="text-lg">
              <p
                v-if="isMaintainerClaimable"
                class="inline-flex items-center gap-1"
              >
                You can claim as a <strong>Maintainer</strong> for
                <ElementAddressBrowserLink
                  :address="addrStatus.reviewerAddr!"
                  :short="false"
                />
              </p>
              <p v-else>You can ask any <strong>Reviewer</strong> to set you as a <strong>Maintainer</strong></p>
            </h2>
            <FormSubmitClaimMaintainer
              :reviewer="addrStatus.reviewerAddr"
              @success="reloadAddrStatus"
            />
            <h2 class="text-lg"> or </h2>
            <FormSubmitInitReviewer @success="reloadAddrStatus" />
          </div>
        </template>
      </EnsureConnected>
    </div>
  </VueWrapper>
</template>
