<script setup lang="ts">
import { ref, reactive, computed, inject, watch } from 'vue'
import {
  NSkeleton, NEmpty,
  NGrid, NGridItem, NFormItemGi, NForm, type FormInst, type FormRules,
} from 'naive-ui';
import type { StandardTokenView, Media, CustomizedTokenDto, TokenIdentity, TokenPaths } from '@shared/flow/entities';
import { maintainerRegisterCustomizedFT, maintainerUpdateCustomizedFT } from '@shared/flow/action/transactions';

import PanelCardWrapper from '@components/partials/PanelCardWrapper.vue';
import ImageUploader from '@components/widgets/ImageUploader.vue';

const props = withDefaults(defineProps<{
  ft?: StandardTokenView,
}>(), {
  ft: undefined,
})

type FormDto = {
  ft: TokenIdentity,
  paths: TokenPaths,
  display: CustomizedTokenDto
}

const formRef = ref<FormInst | null>(null);
const formData = reactive<FormDto>({
  ft: {
    address: "",
    contractName: "",
  },
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

const logos = computed<Media[]>(() => {
  return props.ft?.display?.display?.logos ?? [];
});

const imageUrl = computed({
  get: () => formData?.display?.logo,
  set: (value: string) => {
    formData.display.logo = value;
  }
});

// Watchers and Lifecycle Hooks

watch(() => props.ft, async (ft) => {
  if (ft?.identity.address !== formData?.ft.address
    || ft?.identity.contractName !== formData?.ft.contractName) {
    formData.ft.address = ft?.identity.address ?? "";
    formData.ft.contractName = ft?.identity.contractName ?? "";
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
    class="min-h-lg"
  >
    <NGrid
      :col="12"
      :x-gap="12"
    >
      <NGridItem :span="4">
        <ImageUploader v-model:image="imageUrl" />
        {{ imageUrl }}
      </NGridItem>
    </NGrid>
  </PanelCardWrapper>
</template>
