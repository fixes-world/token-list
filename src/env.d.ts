/// <reference path="../.astro/types.d.ts" />
/// <reference types="astro/client" />

interface ImportMetaEnv {
  readonly MAINTENANCE_MODE: string;

  readonly PUBLIC_FLOW_NETWORK: string;

  // -> Qiniu
  readonly QINIU_ACCESS_KEY: string;
  readonly QINIU_SECRET_KEY: string;
  readonly QINIU_BUCKET: string;

  // Redis
  readonly KV_URL: string;
  readonly KV_REST_API_URL: string;
  readonly KV_REST_API_TOKEN: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

declare namespace App {
  interface Locals {
    isAPIEndpoint: boolean;
  }
}
