<script setup lang="ts">
import { ref, reactive, computed, inject, watch } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import {
  NCollapseTransition, NSwitch,
  NForm, NGrid, NFormItemGi, NInput, type FormInst, type FormRules,
} from 'naive-ui';
// import { getReviewerInfo } from '@shared/flow/action/scripts';
import { FlowSrvKey } from '@shared/flow/utilitites';
import type { ReviewerInfo } from '@shared/flow/entities';
import { useGlobalAccount, useSendingTransaction } from '@components/shared';

import FormSubmitUpdateReviewMetadata from '@components/reviewer/form/FormSubmitUpdateReviewMetadata.vue';

const props = withDefaults(defineProps<{
  reviewerInfo: ReviewerInfo | null,
}>(), {
  reviewerInfo: null,
});

const emits = defineEmits<{
  (e: 'refresh'): void,
}>();

const isSending = useSendingTransaction()

// const breakpoints = useBreakpoints(breakpointsTailwind)
// const isNotMobile = breakpoints.greaterOrEqual('md')

// Reactive Variables

const formEditMetadataRef = ref<FormInst | null>(null);
const formEditMetadata = reactive({
  name: "",
  url: "",
});
const rules = ref<FormRules>({
  name: [
    { required: true, message: 'Name is required', trigger: 'blur' },
    { type: 'string', pattern: /^[\w _]{3,25}$/, message: 'Please Enter 3 to 25 Letters.', trigger: ['input', 'blur'] },
  ],
  url: { required: true, type: 'url', message: 'Invalid URL', trigger: 'blur' },
});

// Functions

// Watchers and Lifecycle Hooks

watch(() => props.reviewerInfo, (newVal) => {
  if (newVal) {
    formEditMetadata.name = newVal?.name || ""
    formEditMetadata.url = newVal?.url || ""
  }
}, { immediate: true })

</script>

<template>
  <NForm
    ref="formEditMetadataRef"
    size="large"
    :model="formEditMetadata"
    :rules="rules"
    :disabled="isSending"
    label-placement="left"
    label-width="auto"
    :show-require-mark="false"
    :show-feedback="true"
    :style="{
      width: '100%',
      minWidth: '280px'
    }"
  >
    <NGrid
      :cols="3"
      :x-gap="12"
    >

      <NFormItemGi
        :span="1"
        path="name"
      >
        <template #label>
          <span class="text-sm text-gray-400">Name</span>
        </template>
        <NInput
          size="small"
          v-model:value="formEditMetadata.name"
          placeholder="Reviewer Name"
          :input-props="{
            autocomplete: 'off',
          }"
        />
      </NFormItemGi>
      <NFormItemGi
        :span="2"
        path="url"
      >
        <template #label>
          <span class="text-sm text-gray-400">Website</span>
        </template>
        <NInput
          size="small"
          v-model:value="formEditMetadata.url"
          placeholder="Reviewer Website URL"
          :input-props="{
            autocomplete: 'off',
          }"
        />
      </NFormItemGi>
      <NFormItemGi
        :span="3"
        :show-feedback="false"
      >
        <FormSubmitUpdateReviewMetadata
          :reviewer-info="reviewerInfo"
          :name="formEditMetadata.name"
          :url="formEditMetadata.url"
          @success="emits('refresh')"
        />
      </NFormItemGi>
    </NGrid>
  </NForm>
</template>
