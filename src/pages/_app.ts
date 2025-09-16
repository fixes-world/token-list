import FCLPlugin from "@shared/flow/plugin";
import hljs from "highlight.js/lib/core";
import bash from "highlight.js/lib/languages/bash";
import js from "highlight.js/lib/languages/javascript";
import json from "highlight.js/lib/languages/json";
import python from "highlight.js/lib/languages/python";
import type { App } from "vue";

export default (app: App) => {
  hljs.registerLanguage("javascript", js);
  hljs.registerLanguage("python", python);
  hljs.registerLanguage("bash", bash);
  hljs.registerLanguage("json", json);

  app.use(FCLPlugin);
};
