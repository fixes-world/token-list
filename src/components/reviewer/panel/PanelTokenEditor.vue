<script setup lang="ts">
import { ref, reactive, computed, inject, watch, h, type VNodeChild, toRaw } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import {
  NSkeleton, NEmpty,
  NGrid, NGridItem, NFormItemGi, NForm, type FormInst, type FormRules,
  NInput, NButton, NDynamicInput,
  NSelect, type SelectOption,
} from 'naive-ui';
import type { StandardTokenView, Media, CustomizedTokenDto, SocialKeyPair, TokenPaths } from '@shared/flow/entities';
import { FlowSrvKey } from '@shared/flow/utilitites';
import { getFTContractStatus } from '@shared/flow/action/scripts';
import { useGlobalAccount, useSendingTransaction } from '@components/shared'

import PanelCardWrapper from '@components/partials/PanelCardWrapper.vue';
import ImageUploader from '@components/widgets/ImageUploader.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import ItemFungibleTokenStatus from '@components/items/ItemFungibleTokenStatus.vue';
import FormSubmitCustomizeFT from '@components/reviewer/form/FormSubmitCustomizeFT.vue';

const props = withDefaults(defineProps<{
  ft?: StandardTokenView,
}>(), {
  ft: undefined,
})

const emits = defineEmits<{
  (e: 'refresh'): void
}>();

const breakpoints = useBreakpoints(breakpointsTailwind)
const isNotMobile = breakpoints.greaterOrEqual('md')

const acctName = useGlobalAccount()
const isSending = useSendingTransaction()

const logos = computed<Media[]>(() => {
  return props.ft?.display?.display?.logos ?? [];
});

type FormDto = {
  paths: TokenPaths,
  display: CustomizedTokenDto
}

const formRef = ref<FormInst | null>(null);
const formData = reactive<FormDto>({
  paths: {
    vault: "",
    receiver: "",
    balance: "",
  },
  display: {
    logo: "",
    symbol: "",
    name: "",
    description: "",
    externalURL: "",
    social: [],
  },
});
const rules = ref<FormRules>({
  paths: {
    "vault": { required: true, message: 'Vault is required', trigger: ['change'] },
    "receiver": { required: true, message: 'Receiver is required', trigger: ['change'] },
    "balance": { required: true, message: 'Balance is required', trigger: ['change'] },
  },
  display: {
    logo: { required: true, message: 'Token Icon is required', trigger: ['change', 'blur'] },
    symbol: [
      { required: true, message: 'Symbol is required', trigger: 'blur' },
      { type: 'string', pattern: /^[A-Z][A-Z0-9]{2,7}$/, message: 'Please Enter 3~8 Uppercase Letters.', trigger: ['input', 'blur'] },
    ],
    name: [
      { required: true, message: 'Name is required', trigger: 'blur' },
      { type: 'string', pattern: /^[\w _]{3,25}$/, message: 'Please Enter 3 to 25 Letters.', trigger: ['input', 'blur'] },
    ],
    description: { type: 'string', max: 250, message: 'Description is required', trigger: 'blur' },
    externalURL: { type: 'url', message: 'Invalid URL', trigger: 'blur' },
  }
});

const isLoadingFTStatus = ref(false)

const imageUrl = computed({
  get: () => formData?.display?.logo,
  set: (value: string) => {
    formData.display.logo = value;
  }
});

const socialTypesOptions: SelectOption[] = [
  { value: "twitter", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:logo-x w-4 h-4' })) },
  { value: "telegram", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:send-alt-filled w-4 h-4' })) },
  { value: "discord", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:logo-discord w-4 h-4' })) },
  { value: "github", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:logo-github w-4 h-4' })) },
  { value: "medium", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:logo-medium w-4 h-4' })) },
  { value: "linkedin", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:logo-linkedin w-4 h-4' })) },
  { value: "youtube", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:logo-youtube w-4 h-4' })) },
  { value: "instagram", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:logo-instagram w-4 h-4' })) },
  { value: "facebook", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:logo-facebook w-4 h-4' })) },
];

// Handlers and Functions

async function loadFTStatus() {
  if (!props.ft) return;

  isLoadingFTStatus.value = true;
  console.log("Loading FT: ", props.ft?.identity.address, props.ft?.identity.contractName)
  const status = await getFTContractStatus(props.ft?.identity.address, props.ft?.identity.contractName);
  if (status) {
    formData.paths.vault = status.vaultPath;
    for (let key in status.publicPaths) {
      if (key.includes("FungibleToken.Receiver")) {
        formData.paths.receiver = status.publicPaths[key];
      } else if (key.includes("FungibleToken.Balance")) {
        formData.paths.balance = status.publicPaths[key];
      }
    }
  }
  isLoadingFTStatus.value = false;
}

function onSocialCreate(): SocialKeyPair {
  let exists = formData.display.social ?? []
  // add a new social link
  const unusedSocials: string[] = []
  for (let one of socialTypesOptions) {
    if (!exists.find((s) => s.key === one.value)) {
      unusedSocials.push(String(one.value))
    }
  }
  return { key: unusedSocials[0], value: "" };
}

function renderLabel(option: SelectOption, icon: VNodeChild): VNodeChild {
  return h('div', { class: 'w-full flex items-center gap-2' }, [icon, option.value]);
}

// function renderOption(info: { node: VNode, option: SelectOption }): VNodeChild {
//   return h('div', { class: 'max-w-12  flex justify-center-center' }, [info.node]);
// }

// Watchers and Lifecycle Hooks

watch(() => props.ft, async (ft, oldFt) => {
  if (ft?.identity.address !== oldFt?.identity.address
    || ft?.identity.contractName !== oldFt?.identity.contractName) {
    formData.paths.vault = ft?.path?.vault ?? "";
    formData.paths.receiver = ft?.path?.receiver ?? "";
    formData.paths.balance = ft?.path?.balance ?? "";
    formData.display.logo = logos.value[0]?.uri ?? "";
    formData.display.symbol = ft?.display?.display?.symbol ?? "";
    formData.display.name = ft?.display?.display?.name ?? "";
    formData.display.description = ft?.display?.display?.description ?? "";
    formData.display.externalURL = ft?.display?.display?.externalURL ?? "";
    formData.display.social = Object.entries(ft?.display?.display?.social ?? {}).map(([key, value]) => ({ key, value }));
  }
}, { immediate: true });

</script>

<template>
  <PanelCardWrapper
    size="medium"
    class="min-h-lg min-w-sm"
  >
    <NEmpty
      v-if="!ft"
      description="Failed to load fungible token."
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
      <ItemFungibleTokenStatus
        class="!mb-4"
        :item="ft.identity"
      />
      <NGrid
        :cols="6"
        :x-gap="12"
      >
        <NFormItemGi
          :span="6"
          path="paths.vault"
          :show-label="false"
          :show-feedback="false"
        >
          <div class="mb-4 flex items-center justify-between gap-2 md:gap-4">
            <ImageUploader
              class="flex-none !w-[96px]"
              v-model:image="imageUrl"
              :type="ft.display?.display?.logos?.[0]?.type"
            />
            <NButton
              v-if="!formData.paths.vault"
              size="medium"
              type="primary"
              strong
              round
              :loading="isLoadingFTStatus"
              :disabled="isSending"
              @click="loadFTStatus"
            > Load Vault Info </NButton>
            <div
              v-else
              class="flex-auto my-2 flex flex-col justify-center gap-1"
            >
              <ElementWrapper
                title="Vault Path"
                direction="auto"
                position="left"
              >
                {{ formData.paths.vault }}
              </ElementWrapper>
              <ElementWrapper
                title="Receiver Path"
                direction="auto"
                position="left"
              >
                {{ formData.paths.receiver }}
              </ElementWrapper>
              <ElementWrapper
                title="Balance Path"
                direction="auto"
                position="left"
              >
                {{ formData.paths.balance }}
              </ElementWrapper>
            </div>
          </div>
        </NFormItemGi>
        <NFormItemGi
          :span="6"
          path="display.symbol"
        >
          <template #label>
            <span class="text-sm text-gray-500">Symbol</span>
          </template>
          <NInput
            size="small"
            v-model:value="formData.display.symbol"
            placeholder="Token Symbol"
            :input-props="{
              autocomplete: 'off',
              autocorrect: 'off',
              autocapitalize: 'characters',
              spellcheck: 'false',
            }"
          />
        </NFormItemGi>
        <NFormItemGi
          :span="6"
          path="display.name"
        >
          <template #label>
            <span class="text-sm text-gray-500">Name</span>
          </template>
          <NInput
            size="small"
            v-model:value="formData.display.name"
            placeholder="Display Name"
            :input-props="{ autocomplete: 'off' }"
          />
        </NFormItemGi>
        <NFormItemGi
          :span="6"
          path="display.logo"
        >
          <template #label>
            <span class="text-sm text-gray-500">Icon</span>
          </template>
          <NInput
            size="small"
            v-model:value="imageUrl"
            placeholder="Token Icon"
            :input-props="{ autocomplete: 'off', type: 'url' }"
          />
        </NFormItemGi>
        <NFormItemGi
          :span="6"
          path="display.externalURL"
        >
          <template #label>
            <span class="text-sm text-gray-500">Website</span>
          </template>
          <NInput
            size="small"
            v-model:value="formData.display.externalURL"
            placeholder="Website or Project Link"
            :input-props="{ autocomplete: 'off', type: 'url' }"
          />
        </NFormItemGi>
        <NFormItemGi
          :span="6"
          path="display.description"
        >
          <template #label>
            <span class="text-sm text-gray-500">Description</span>
          </template>
          <NInput
            size="small"
            round
            type="textarea"
            v-model:value="formData.display.description"
            placeholder="Description"
            :input-props="{ autocomplete: 'off' }"
          />
        </NFormItemGi>
        <NFormItemGi
          :span="6"
          path="display.social"
        >
          <NDynamicInput
            size="small"
            :max="9"
            v-model:value="formData.display.social"
            :on-create="onSocialCreate"
          >
            <template #create-button-default>
              Add Social Link
            </template>
            <template #default="{ index }">
              <div class="flex items-center w-full gap-2">
                <NSelect
                  class="!w-40"
                  size="small"
                  placeholder="Social"
                  v-model:value="formData.display.social[index].key"
                  :options="socialTypesOptions"
                  :disabled="isSending"
                  :input-props="{ autocomplete: 'off' }"
                />
                <NInput
                  v-model:value="formData.display.social[index].value"
                  placeholder="Input URL"
                  type="text"
                  :input-props="{ autocomplete: 'off', type: 'url' }"
                  size="small"
                />
              </div>
            </template>
          </NDynamicInput>
        </NFormItemGi>
      </NGrid>
    </NForm>
    <template
      v-if="!!ft"
      #action
    >
      <FormSubmitCustomizeFT
        :ft="ft"
        :paths="formData.paths"
        :display="formData.display"
        @success="emits('refresh')"
      />
    </template>
  </PanelCardWrapper>
</template>
