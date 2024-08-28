<script setup lang="ts">
import { ref, reactive, computed, inject, watch, h, type VNodeChild, toRaw } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import {
  NEmpty,
  NGrid, NFormItemGi, NForm, type FormInst, type FormRules,
  NSelect, type SelectOption, NDynamicTags,
} from 'naive-ui';
import type { TagableItem } from '@shared/flow/entities';
import { EvaluationType } from '@shared/flow/enums';
import { parseReviewData } from '@shared/flow/utilitites';
import { useSendingTransaction } from '@components/shared';

import PanelCardWrapper from '@components/partials/PanelCardWrapper.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import FormSubmitReviewToken from '@components/reviewer/form/FormSubmitReviewToken.vue';

const props = withDefaults(defineProps<{
  isNft?: boolean,
  item?: TagableItem,
}>(), {
  isNft: false,
  item: undefined,
})

const emits = defineEmits<{
  (e: 'refresh'): void
}>();

const breakpoints = useBreakpoints(breakpointsTailwind)
const isNotMobile = breakpoints.greaterOrEqual('md')

const isSending = useSendingTransaction()

type FormDto = {
  rank: EvaluationType,
  tags: string[],
}

const formRef = ref<FormInst | null>(null);
const formData = reactive<FormDto>({
  rank: EvaluationType.UNVERIFIED,
  tags: [],
});
const rules = ref<FormRules>({
  rank: [
    {
      required: true,
      message: 'Rank is required',
      trigger: ['change'],
    },
    {
      type: 'enum',
      enum: Object.values(EvaluationType),
      message: 'Invalid Rank',
      trigger: ['change'],
    },
  ],
  tags: {
    type: 'array',
    trigger: ['change'],
    validator(rule: unknown, value: string[]) {
      if (value.length > 5) return new Error('Tags must be less than 5');
      return true
    }
  }
});

const rankOptions: SelectOption[] = [
  { value: EvaluationType.UNVERIFIED, label: "Unverified" },
  { value: EvaluationType.PENDING, label: "Pending" },
  { value: EvaluationType.VERIFIED, label: "Verified" },
  { value: EvaluationType.FEATURED, label: "Featured" },
];

// Handlers and Functions

// function renderOption(info: { node: VNode, option: SelectOption }): VNodeChild {
//   return h('div', { class: 'max-w-12  flex justify-center-center' }, [info.node]);
// }

// Watchers and Lifecycle Hooks

watch(() => props.item, async (newVal, oldVal) => {
  if (newVal && (newVal?.identity.address !== oldVal?.identity.address
    || newVal?.identity.contractName !== oldVal?.identity.contractName)) {
    const data = parseReviewData(newVal)
    formData.rank = data.rank
    formData.tags = data.tags
  }
}, { immediate: true });

</script>

<template>
  <PanelCardWrapper
    size="medium"
    class="min-h-[12rem] min-w-sm"
  >
    <template #header>
      <h2 class="py-1 italic highlight font-semibold">Evaluate and Review</h2>
    </template>
    <NEmpty
      v-if="!item"
      description="Failed to load data."
      class="my-6"
    />
    <NForm
      v-else
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
        :cols="6"
        :x-gap="12"
        :y-gap="8"
      >
        <NFormItemGi
          :span="6"
          label="Rank"
          prop="rank"
          :show-feedback="false"
        >
          <NSelect
            v-model:value="formData.rank"
            :options="rankOptions"
            placeholder="Select Rank"
          />
        </NFormItemGi>
        <NFormItemGi
          :span="6"
          label="Tags"
          prop="tags"
        >
          <NDynamicTags
            v-model:value="formData.tags"
            round
            :max="5"
            type="info"
          />
        </NFormItemGi>
      </NGrid>
    </NForm>
    <template
      v-if="!!item"
      #action
    >
      <FormSubmitReviewToken
        :is-nft="props.isNft"
        :item="item"
        :rank="formData.rank"
        :tags="formData.tags"
        @success="emits('refresh')"
      />
    </template>
  </PanelCardWrapper>
</template>
