import type { App } from "vue";
import FCLPlugin from "@shared/flow/plugin";

export default (app: App) => {
  app.use(FCLPlugin);
};
