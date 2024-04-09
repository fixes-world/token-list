/// <reference types="astro/client" />

interface ImportMetaEnv {
  readonly PUBLIC_FLOW_NETWORK: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

declare namespace App {
  interface Locals {
    // TODO: Define your own type
  }
}
