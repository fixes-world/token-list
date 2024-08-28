<script setup lang="ts">
import { ref, reactive, computed, inject, watch, h, type VNodeChild, toRaw } from 'vue'
import { breakpointsTailwind, useBreakpoints } from '@vueuse/core';
import {
  NSkeleton, NEmpty,
  NGrid, NGridItem, NFormItemGi, NForm, type FormInst, type FormRules,
  NInput, NButton, NDynamicInput,
  NSelect, type SelectOption,
} from 'naive-ui';
import type { Media, SocialKeyPair, NFTCollectionDisplayDto, StandardNFTCollectionView } from '@shared/flow/entities';
import { useSendingTransaction } from '@components/shared'

import PanelCardWrapper from '@components/partials/PanelCardWrapper.vue';
import ImageUploader from '@components/widgets/ImageUploader.vue';
import LoadingFrame from '@components/partials/LoadingFrame.vue';
import ItemMedia from '@components/items/ItemMedia.vue';
import ElementWrapper from '@components/items/cardElements/ElementWrapper.vue';
import FormSubmitCustomizeNFT from '@components/reviewer/form/FormSubmitCustomizeNFT.vue';

const props = withDefaults(defineProps<{
  nft?: StandardNFTCollectionView,
}>(), {
  nft: undefined,
})

const emits = defineEmits<{
  (e: 'refresh'): void
}>();

const breakpoints = useBreakpoints(breakpointsTailwind)
const isNotMobile = breakpoints.greaterOrEqual('md')

const isSending = useSendingTransaction()

type FormDto = {
  display: NFTCollectionDisplayDto
}

const formRef = ref<FormInst | null>(null);
const formData = reactive<FormDto>({
  display: {
    name: "",
    description: "",
    externalURL: "",
    squareImage: "",
    bannerImage: "",
    social: [],
  },
});
const rules = ref<FormRules>({
  display: {
    name: [
      { required: true, message: 'Name is required', trigger: 'blur' },
      { type: 'string', pattern: /^[\w _()]{3,50}$/, message: 'Please Enter 3 to 50 Letters.', trigger: ['input', 'blur'] },
    ],
    bannerImage: { required: true, message: 'NFT Banner Image is required', trigger: ['change', 'blur'] },
    squareImage: { required: true, message: 'NFT Square Image is required', trigger: ['change', 'blur'] },
    description: { type: 'string', max: 250, message: 'Description is required', trigger: 'blur' },
    externalURL: { type: 'url', message: 'Invalid URL', trigger: 'blur' },
  }
});

const showExtraVaultInput = ref(false)
const extraVaultAddr = ref<string | null>(null)

const squareImageUrl = computed({
  get: () => formData?.display?.squareImage,
  set: (value: string) => {
    formData.display.squareImage = value;
  }
});

const bannerImageUrl = computed({
  get: () => formData?.display?.bannerImage,
  set: (value: string) => {
    formData.display.bannerImage = value;
  }
});

const bannerMedia = computed<Media | undefined>(() => {
  return bannerImageUrl.value
    ? { uri: bannerImageUrl.value, type: props.nft?.display?.display.bannerImage?.type ?? 'image' }
    : undefined;
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
  { value: "documentation", label: (opt) => renderLabel(opt, h('span', { class: 'i-carbon:book w-4 h-4' })) },
  { value: "coingeckoId", label: (opt) => h('span', {}, "CoinGecko ID") },
  { value: "bridgeContract", label: (opt) => h('span', {}, "Bridge Contract") },
  { value: "other", label: (opt) => h('span', {}, "Other") },
];

// Handlers and Functions

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

watch(() => props.nft, async (newVal, oldVal) => {
  if (newVal?.identity.address !== oldVal?.identity.address
    || newVal?.identity.contractName !== oldVal?.identity.contractName) {
    showExtraVaultInput.value = false;
    extraVaultAddr.value = null;

    formData.display.name = newVal?.display?.display?.name ?? "";
    formData.display.squareImage = newVal?.display?.display?.squareImage?.uri ?? "";
    formData.display.bannerImage = newVal?.display?.display?.bannerImage?.uri ?? "";
    formData.display.description = newVal?.display?.display?.description ?? "";
    formData.display.externalURL = newVal?.display?.display?.externalURL ?? "";
    formData.display.social = Object.entries(newVal?.display?.display?.social ?? {}).map(([key, value]) => ({ key, value }));
  }
}, { immediate: true });

</script>

<template>
  <PanelCardWrapper
    size="medium"
    class="min-h-lg min-w-sm"
  >
    <template #header>
      <h2 class="py-1 italic highlight font-semibold">NFT Collection Metadata</h2>
    </template>
    <LoadingFrame
      :is-empty="!nft"
      empty-text="Failed to load non-fungible token."
    >
      <ItemMedia
        class="w-full !max-h-40 rounded-lg opacity-10"
        :media="bannerMedia"
        :alt="`Banner Image for ${nft?.display?.display?.name ?? 'NFT Collection'}`"
        width="100%"
        :preview-disabled="false"
      />
      <NForm
        v-if="nft"
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
                v-model:image="squareImageUrl"
                :type="nft.display?.display?.squareImage?.type"
              />
              <div class="flex-auto my-2 flex flex-col justify-center gap-1">
                <ElementWrapper
                  title="Storage Path"
                  direction="auto"
                  position="left"
                >
                  {{ nft.paths.storage }}
                </ElementWrapper>
                <ElementWrapper
                  title="Public Path"
                  direction="auto"
                  position="left"
                >
                  {{ nft.paths.public }}
                </ElementWrapper>
              </div>
            </div>
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
            path="display.squareImage"
          >
            <template #label>
              <span class="text-sm text-gray-500">Icon</span>
            </template>
            <NInput
              size="small"
              v-model:value="squareImageUrl"
              placeholder="NFT Collection Square Icon"
              :input-props="{ autocomplete: 'off', type: 'url' }"
            />
          </NFormItemGi>
          <NFormItemGi
            :span="6"
            path="display.bannerImage"
          >
            <template #label>
              <span class="text-sm text-gray-500">Banner</span>
            </template>
            <NInput
              size="small"
              v-model:value="bannerImageUrl"
              placeholder="NFT Collection Banner Icon"
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
                Add Social Links or Extensions
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
                    placeholder="Input Link or ID Handle"
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
    </LoadingFrame>
    <template
      v-if="!!nft"
      #action
    >
      <FormSubmitCustomizeNFT
        :nft="nft"
        :display="formData.display"
        @success="emits('refresh')"
      />
    </template>
  </PanelCardWrapper>
</template>
