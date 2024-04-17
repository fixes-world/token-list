import { defineConfig } from "astro/config";
import UnoCSS from "unocss/astro";
import vue from "@astrojs/vue";
import svgLoader from "vite-svg-loader";
import vercel from "@astrojs/vercel/serverless";

// https://astro.build/config
export default defineConfig({
  site: "https://token-list.fixes.world",
  integrations: [
    vue({
      appEntrypoint: "/src/pages/_app",
    }),
    UnoCSS({
      injectReset: true,
    }),
  ],
  output: "server",
  adapter: vercel({
    functionPerRoute: false,
    imageService: true,
    maxDuration: 180,
  }),
  vite: {
    assetsInclude: ["**/*.cdc"],
    plugins: [svgLoader()],
    ssr: {
      external: ["@onflow/fcl", "@onflow/fcl-wc"],
    },
  },
});
