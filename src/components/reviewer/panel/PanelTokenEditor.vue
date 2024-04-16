<script setup lang="ts">
import { ref, reactive, computed, inject, watch } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import {
  NSkeleton, NEmpty,
  NGrid, NGridItem, NFormItemGi, NForm, type FormInst, type FormRules,
  NInput, NButton,
} from 'naive-ui';
import type { StandardTokenView, Media, CustomizedTokenDto, TokenIdentity, TokenPaths } from '@shared/flow/entities';
import { FlowSrvKey } from '@shared/flow/utilitites';
import { maintainerRegisterCustomizedFT, maintainerUpdateCustomizedFT } from '@shared/flow/action/transactions';
import { getFTContractStatus } from '@shared/flow/action/scripts';
import { useGlobalAccount, useSendingTransaction } from '@components/shared'

import PanelCardWrapper from '@components/partials/PanelCardWrapper.vue';
import ImageUploader from '@components/widgets/ImageUploader.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import ItemFungibleTokenStatus from '@components/items/ItemFungibleTokenStatus.vue';

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

const flowSrv = inject(FlowSrvKey)
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
    social: {},
  },
});
const rules = ref<FormRules>({
  "paths.vault": [
    { required: true, message: 'Vault is required', trigger: ['change'] }
  ],
});

const isLoadingFTStatus = ref(false)

const imageUrl = computed({
  get: () => formData?.display?.logo,
  set: (value: string) => {
    formData.display.logo = value;
  }
});

// Handlers and Functions

async function loadFTStatus() {
  if (!flowSrv) return;
  if (!props.ft) return;

  isLoadingFTStatus.value = true;
  console.log("Loading FT: ", props.ft?.identity.address, props.ft?.identity.contractName)
  const status = await getFTContractStatus(flowSrv, props.ft?.identity.address, props.ft?.identity.contractName);
  if (status) {
    formData.paths.vault = status.vaultPath;
    for (let key in status.publicPaths) {
      console.log("Path Key: ", key, 'Path Value: ', status.publicPaths[key]);
      if (key.includes("FungibleToken.Receiver")) {
        formData.paths.receiver = status.publicPaths[key];
      } else if (key.includes("FungibleToken.Balance")) {
        formData.paths.balance = status.publicPaths[key];
      }
    }
  }
  isLoadingFTStatus.value = false;
}

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
    formData.display.social = ft?.display?.display?.social ?? {};
  }
});

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
      v-model="formData"
      :rules="rules"
      :disabled="isSending"
      :label-placement="!isNotMobile ? 'top' : 'left'"
      :show-require-mark="false"
      :style="{
        width: '100%',
        minWidth: '280px'
      }"
    >
      <ItemFungibleTokenStatus
        class="!mb-3"
        :item="ft.identity"
      />
      <NGrid
        :cols="9"
        :x-gap="24"
        :y-gap="12"
      >
        <NFormItemGi
          :span="9"
          path="paths.vault"
          :show-label="false"
          :show-feedback="false"
        >
          <div class="flex items-center justify-between gap-2 md:gap-4">
            <ImageUploader
              class="flex-none !w-[96px]"
              v-model:image="imageUrl"
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
          :span="9"
          path="display.symbol"
        >
          <template #label>
            <span class="text-sm text-gray-500">Symbol</span>
          </template>
          <NInput
            size="small"
            round
            v-model:value="formData.display.symbol"
            placeholder="Please input FT Symbol"
            :input-props="{
              autocomplete: 'off',
              autocorrect: 'off',
              autocapitalize: 'characters',
              spellcheck: 'false',
            }"
          />
        </NFormItemGi>
      </NGrid>
    </NForm>
  </PanelCardWrapper>
</template>
