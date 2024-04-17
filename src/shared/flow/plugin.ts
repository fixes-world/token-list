import type { App, ObjectPlugin } from "vue";
import { FlowSrvKey } from "./utilitites";
import { getFlowInstance } from "./flow.service.factory";

const FCLPlugin: ObjectPlugin = {
  install: async (app: App, _options: any) => {
    app.provide(FlowSrvKey, await getFlowInstance());
  },
};

export default FCLPlugin;
