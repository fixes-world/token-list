<script setup lang="ts">
import { ref, reactive, computed, inject, watch } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import {
  NCollapseTransition, NSwitch,
  NForm, NGrid, NFormItemGi, NInput, type FormInst, type FormRules,
} from 'naive-ui';
import type { ReviewerInfo } from '@shared/flow/entities';
import { useGlobalAccount, useSendingTransaction } from '@components/shared';

import FormSubmitAddMaintainer from './FormSubmitAddMaintainer.vue';

const props = withDefaults(defineProps<{
  isNft?: boolean
  reviewerInfo: ReviewerInfo | null,
}>(), {
  isNft: false,
  reviewerInfo: null,
});

const emits = defineEmits<{
  (e: 'refresh'): void,
}>();

const isSending = useSendingTransaction()

const breakpoints = useBreakpoints(breakpointsTailwind)
const isNotMobile = breakpoints.greaterOrEqual('md')

// Reactive Variables

const formRef = ref<FormInst | null>(null);
const formData = reactive({
  address: "",
});
const rules = ref<FormRules>({
  address: [
    { required: true, message: 'Name is required', trigger: 'blur' },
    { type: 'string', pattern: /^0x[0-9A-Fa-f]{16}$/, message: 'Not a valid Flow Address', trigger: 'blur' },
  ]
});

// Functions

function reset() {
  formData.address = ""
}

function onSuccess() {
  reset()
  emits('refresh')
}

// Watchers and Lifecycle Hooks

watch(() => props.reviewerInfo, (newVal) => {
  if (newVal) {
    reset()
  }
}, { immediate: true })

</script>

<template>
  <NForm
    ref="formRef"
    size="large"
    :model="formData"
    :rules="rules"
    :disabled="isSending"
    :label-placement="!isNotMobile ? 'top' : 'left'"
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
        :span="3"
        path="address"
      >
        <template #label>
          <span class="text-sm text-gray-400">Maintainer</span>
        </template>
        <NInput
          size="small"
          v-model:value="formData.address"
          placeholder="Input Flow Address"
          :input-props="{
            autocomplete: 'off',
          }"
        />
      </NFormItemGi>
      <NFormItemGi
        :span="3"
        :show-feedback="false"
      >
        <FormSubmitAddMaintainer
          :is-nft="props.isNft"
          :reviewer-info="reviewerInfo"
          :address="formData.address"
          @success="onSuccess"
        />
      </NFormItemGi>
    </NGrid>
  </NForm>
</template>
