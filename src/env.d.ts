/// <reference types="astro/client" />

interface ImportMetaEnv {
  readonly PUBLIC_FLOW_NETWORK: string;
  readonly PUBLIC_NFTSTORAGE_KEY: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

declare namespace App {
  interface Locals {
    // TODO: Define your own type
  }
}
