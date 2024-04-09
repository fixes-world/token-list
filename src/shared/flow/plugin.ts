import type { App, ObjectPlugin } from "vue";
import flowJSON from "@flow.json" assert { type: "json" };
import { FlowService } from "./flow.service";
import { FlowSrvKey } from "./utilitites";

const FCLPlugin: ObjectPlugin = {
  install: async (app: App, _options: any) => {
    const srv = new FlowService(flowJSON);
    app.provide(FlowSrvKey, srv);
  },
};

export default FCLPlugin;
