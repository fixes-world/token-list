import type { App } from "vue";
import hljs from "highlight.js/lib/core";
import js from "highlight.js/lib/languages/javascript";
import python from "highlight.js/lib/languages/python";
import bash from "highlight.js/lib/languages/bash";
import json from "highlight.js/lib/languages/json";

import FCLPlugin from "@shared/flow/plugin";

export default (app: App) => {
  hljs.registerLanguage("javascript", js);
  hljs.registerLanguage("python", python);
  hljs.registerLanguage("bash", bash);
  hljs.registerLanguage("json", json);

  app.use(FCLPlugin);
};
