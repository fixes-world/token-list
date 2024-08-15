<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import {
  useMessage,
  NUpload, NUploadDragger,
  type UploadFileInfo, type UploadCustomRequestOptions
} from 'naive-ui';
import * as qiniu from 'qiniu-js';
import { encode } from 'js-base64';

import appInfo from '@shared/config/info';
import { loadOrGenerateUploadToken } from '@shared/api/utilties.client';

const props = withDefaults(defineProps<{
  image?: string
  type?: string
  disabled?: boolean
}>(), {
  image: undefined,
  type: 'image/*',
  disabled: false,
})

const emit = defineEmits<{
  (e: 'update:image', url: string): void
  (e: 'update:type', val: string): void
}>()

const message = useMessage();

const uploading = ref(false)
const lastUploaded = ref('')
const fileList = ref<UploadFileInfo[]>([])

// Funcations

async function beforeUpload(data: {
  file: UploadFileInfo,
  fileList: UploadFileInfo[]
}) {
  let size = data.file.file?.size ?? 0
  if (size === 0) {
    message.error('File size is 0.')
    return false
  }
  // File 的 size 最多 2M
  if (size > 2 * 1024 * 1024) {
    message.error('File size exceeds 2MB.')
    return false
  }
  return true
}


async function uploadImage(options: UploadCustomRequestOptions) {
  if (!options.file.file) {
    message.error('No file selected.')
    return
  }
  const token = await loadOrGenerateUploadToken()
  uploading.value = true
  const fname = options.file.file.name
  const encodedFname = encode(fname)
  const key = encodedFname.length + encodedFname.slice(0, Math.min(10, encodedFname.length)) + Date.now().toFixed(0)
  const observable = qiniu.upload(options.file.file, key, token, { fname }, { useCdnDomain: true })
  observable.subscribe({
    next: (res) => {
      options.onProgress({ percent: res.total.percent })
    },
    error: (err) => {
      uploading.value = false
      console.error(err)
      message.error('Failed to upload image to Qiniu.')
      options.onError()
    },
    complete: (res) => {
      uploading.value = false
      const imageUrl = `${appInfo.staticHost}/${res.key}`
      // update last file
      lastUploaded.value = imageUrl
      emit('update:image', imageUrl)
      emit('update:type', res.mimeType ?? options.file.file?.type)
      options.onFinish()
      console.log('Image uploaded successfully:', imageUrl)
      message.success('Image uploaded successfully!')
    }
  })
}

function handleUploadChange(data: { fileList: UploadFileInfo[] }) {
  fileList.value = data.fileList
  if (data.fileList.length === 0) {
    emit('update:image', '')
    emit('update:type', '')
    resetDefaultList()
  }
}

function resetDefaultList() {
  if (props.image) {
    const name = props.image.split('/').pop();
    const isQiniu = props.image.startsWith(appInfo.staticHost)
    const fileRef: UploadFileInfo = {
      id: '1',
      name: name ?? "unknown",
      status: 'finished',
      url: props.image,
      type: props.type ?? 'image/*',
      thumbnailUrl: isQiniu ? `${props.image}-thumbnail.png` : undefined,
    }
    fileList.value = [fileRef]
  } else {
    fileList.value = []
  }
  lastUploaded.value = ''
}

watch(() => props.image, (newVal) => {
  if (newVal) {
    const currFile = fileList.value[0]
    if (currFile && (currFile.url === newVal || lastUploaded.value === newVal)) {
      return
    }
  }
  resetDefaultList()
}, { immediate: true })

</script>

<template>
  <NUpload
    accept="image/png, image/jpeg, image/gif, image/svg+xml"
    list-type="image-card"
    :custom-request="uploadImage"
    name="image"
    response-type="json"
    v-model:file-list="fileList"
    :max="1"
    :multiple="false"
    :disabled="disabled"
    @before-upload="beforeUpload"
    @change="handleUploadChange"
  >
    <NUploadDragger>
      <div class="w-hull flex flex-col items-center justify-center text-gray-400/60">
        <span class="mx-a i-carbon:image w-8 h-8"/>
        <span class="text-xs"> <= 2MB</span>
      </div>
    </NUploadDragger>
  </NUpload>
</template>
