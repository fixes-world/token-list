<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import {
  useMessage,
  NUpload, NUploadDragger,
  type UploadFileInfo, type UploadCustomRequestOptions
} from 'naive-ui';
import { NFTStorage } from "nft.storage";
import appInfo from '@shared/config/info'

const props = withDefaults(defineProps<{
  image?: string
  type?: string
}>(), {
  image: undefined,
  type: 'image/*'
})

const emit = defineEmits<{
  (e: 'update:image', cid: string): void
}>()

const message = useMessage();
const client = new NFTStorage({ token: appInfo.nftStorageKey });

// ipfs uploading related
const uploading = ref(false);
const fileRef = computed<UploadFileInfo | null>(() => {
  if (props.image) {
    const name = props.image.split('/').pop();
    return {
      id: '1',
      name: name ?? "unknown",
      status: 'finished',
      url: getIPFSUrl(props.image),
      type: props.type ?? 'image/*',
    }
  }
  return null
});
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
  // File 的 size 最多 256KB
  if (size > 256 * 1024) {
    message.error('File size exceeds 256KB.')
    return false
  }
  return true
}

async function uploadToIPFS(options: UploadCustomRequestOptions) {
  if (!options.file.file) {
    message.error('No file selected.')
    return
  }
  uploading.value = true
  try {
    options.onProgress({ percent: 10 })
    const cid = await client.storeBlob(options.file.file);
    emit('update:image', getIPFSUrl(cid));
    options.onProgress({ percent: 100 })
    options.onFinish()
    message.success('Image uploaded to IPFS successfully! \n CID: ' + cid)
  } catch (e: any) {
    console.error(e)
    message.error('Failed to upload image to IPFS.')
    options.onError()
  }
  uploading.value = false
}

/**
 * get a ipfs gateway url from ipfs hash
 * @param ipfsHash
 */
function getIPFSUrl(ipfsHash: string) {
  if (ipfsHash.startsWith("http")) {
    return ipfsHash;
  } else {
    return `https://nftstorage.link/ipfs/${ipfsHash}`;
  }
}

function resetDefaultList() {
  fileList.value = fileRef.value ? [fileRef.value] : []
}

function handleUploadChange (data: { fileList: UploadFileInfo[] }) {
  fileList.value = data.fileList
}

watch(() => props.image, () => {
  resetDefaultList()
}, { immediate: true })

</script>

<template>
  <NUpload
    accept="image/png, image/jpeg, image/gif, image/svg+xml"
    list-type="image-card"
    trigger-class=""
    v-model:file-list="fileList"
    :max="1"
    :multiple="false"
    :disabled="uploading"
    :custom-request="uploadToIPFS"
    @before-upload="beforeUpload"
    @change="handleUploadChange"
  >
    <NUploadDragger>
      <div class="w-hull flex flex-col items-center justify-center text-gray-400/60">
        <span class="mx-a i-carbon:image w-8 h-8"/>
        <span class="text-xs"> < 256KB</span>
      </div>
    </NUploadDragger>
  </NUpload>
</template>
