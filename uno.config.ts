// uno.config.ts
import {
  defineConfig,
  presetIcons,
  presetUno,
  presetWebFonts,
  transformerDirectives,
} from "unocss";
import transformerVariantGroup from "@unocss/transformer-variant-group";
import { presetScrollbar } from "unocss-preset-scrollbar";

export default defineConfig({
  transformers: [transformerDirectives(), transformerVariantGroup()],
  presets: [
    presetUno(),
    presetWebFonts({
      provider: "google",
      fonts: {
        title: [
          {
            name: "Changa One",
            italic: true,
          },
          {
            name: "Overpass",
            provider: "none",
          },
          {
            name: "Roboto",
            provider: "none",
          },
          {
            name: "'Helvetica Neue'",
            provider: "none",
          },
          {
            name: "sans-serif",
            provider: "none",
          },
        ],
      },
    }),
    presetIcons({
      extraProperties: {
        display: "inline-block",
        "vertical-align": "middle",
      },
    }),
    presetScrollbar({}),
  ],
});
