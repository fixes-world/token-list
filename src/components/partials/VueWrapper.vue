<script setup lang="ts">
import { computed, onMounted } from 'vue';
import {
  useSharedDark
} from '@components/shared';
import {
  lightTheme, darkTheme,
  NConfigProvider, NGlobalStyle, NMessageProvider,
} from 'naive-ui'
import type { GlobalThemeOverrides } from 'naive-ui'

const props = withDefaults(defineProps<{
  id?: string
  isGlobal?: boolean,
}>(), {
  id: undefined,
  isGlobal: false,
})

const isDark = useSharedDark()
const themeOverrides = computed<GlobalThemeOverrides>(() => {
  return {
    common: Object.assign({
      fontFamily: "Overpass, Roboto, 'Helvetica Neue', Arial, Helvetica, 'Noto Sans', 'PingFang SC', 'Microsoft Yahei', 微软雅黑, 'WenQuanYi Micro Hei', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'",
      fontFamilyMono: "'IBM Plex Mono', Consolas, 'Andale Mono WT', 'Andale Mono', 'Lucida Console', 'Lucida Sans Typewriter', 'DejaVu Sans Mono', 'Bitstream Vera Sans Mono', 'Liberation Mono', 'Nimbus Mono L', Monaco, 'Courier New', Courier, monospace",
    }, !isDark.value ? {
      baseColor: "#f4f6f6",
      primaryColor: "#0ac2c2",
      primaryColorHover: "#75c6d6",
      bodyColor: "#f0f4f4",
      tableColor: "#e9ebeb",
      cardColor: "#e9ebeb",
      successColor: "#63E2B7",
      modalColor: "#f0f4f4",
    } : {
      baseColor: "#f4f6f6",
      primaryColor: "#3df5f5",
      primaryColorHover: "#8ce1f2",
      bodyColor: "#1c282d",
      tableColor: "#212d36",
      cardColor: "#212d36",
      successColor: "#63E2B7",
      modalColor: "#263641",
    }),
    Tabs: {
      // tabTextColorLine: "#FFFFFF99",
    }
  }
})

function addNaiveUIStyleMeta() {
  if (!document || document.getElementById("naive-ui-style")) return
  // naive-ui style injection
  const meta = document.createElement("meta");
  meta.id = "naive-ui-style"
  meta.name = "naive-ui-style";
  document.head.appendChild(meta);
}
addNaiveUIStyleMeta()

onMounted(() => {
  if (props.id && document) {
    // Hide the element
    const el = document.getElementById(props.id)
    if (el) {
      el.style.display = "none"
    }
  }
})

</script>

<template>
  <NConfigProvider
    :theme="isDark ? darkTheme : lightTheme"
    :theme-overrides="themeOverrides"
  >
    <NMessageProvider placement="top">
      <slot />
    </NMessageProvider>
    <template v-if="isGlobal">
      <NGlobalStyle />
    </template>
  </NConfigProvider>
</template>
