<script setup lang="ts">
import { ref, reactive, computed, inject, watch } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import {
  NCollapseTransition, NSwitch,
  NForm, NGrid, NFormItemGi, NInput, type FormInst, type FormRules,
} from 'naive-ui';
import { getReviewerInfo } from '@shared/flow/action/scripts';
import { FlowSrvKey } from '@shared/flow/utilitites';
import type { ReviewerInfo } from '@shared/flow/entities';
import { useGlobalAccount, useSendingTransaction } from '@components/shared';

import ElementAddressBrowserLink from '@components/items/cardElements/ElementAddressBrowserLink.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import FormReviewerMetadata from '@components/reviewer/form/FormReviewerMetadata.vue';

const props = defineProps<{
  reviewer?: string
}>();

const flowSrv = inject(FlowSrvKey);
const acctName = useGlobalAccount();
const isSending = useSendingTransaction()

// const breakpoints = useBreakpoints(breakpointsTailwind)
// const isNotMobile = breakpoints.greaterOrEqual('md')

// Reactive Variables

const showEdit = ref(false)
const isFirstLoading = ref(false)

const reviewerInfo = ref<ReviewerInfo | null>(null)

// Functions

async function loadReviewerMetadata() {
  if (!flowSrv) return
  if (!props.reviewer) return

  reviewerInfo.value = await getReviewerInfo(flowSrv, props.reviewer)
}

async function refresh() {
  isFirstLoading.value = true
  // load reviewer metadata
  await loadReviewerMetadata()
  isFirstLoading.value = false
}

// Watchers and Lifecycle Hooks

watch(acctName, refresh, { immediate: true })

</script>

<template>
  <div
    v-if="reviewer"
    class="flex flex-col"
  >
    <div class="flex items-center justify-between gap-2">
      <div class="flex flex-wrap items-center gap-2 italic text-gray-400/60 font-semibold">
        <h2 class="text-lg">
          Edit as Reviewer
        </h2>
        <ElementAddressBrowserLink
          :address="reviewer"
          :short="false"
        />
      </div>
      <NSwitch
        size="small"
        v-model:value="showEdit"
      >
        <template #checked>
          <span class="text-xs">Edit</span>
        </template>
        <template #unchecked>
          <span class="text-xs">View</span>
        </template>
      </NSwitch>
    </div>
    <div
      v-if="reviewerInfo && !showEdit"
      class="flex flex-col gap-1 text-xs font-semibold"
    >
      <ElementWrapper
        v-if="reviewerInfo?.name"
        direction="row"
        title="Name"
      >
        {{ reviewerInfo?.name }}
      </ElementWrapper>
      <ElementWrapper
        v-if="reviewerInfo?.url"
        direction="row"
        title="Website"
      >
        <a
          :href="reviewerInfo.url"
          target="_blank"
        >{{ reviewerInfo.url }}</a>
      </ElementWrapper>
    </div>
    <NCollapseTransition v-else-if="showEdit">
      <FormReviewerMetadata
        :reviewer-info="reviewerInfo"
        @refresh="refresh"
      />
    </NCollapseTransition>
  </div>
</template>
