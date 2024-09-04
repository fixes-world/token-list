/// <reference types="astro/client" />

interface ImportMetaEnv {
  readonly MAINTENANCE_MODE: string;

  readonly PUBLIC_FLOW_NETWORK: string;
  readonly PUBLIC_NFTSTORAGE_KEY: string;

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
