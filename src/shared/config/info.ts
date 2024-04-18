const network = import.meta.env.PUBLIC_FLOW_NETWORK ?? "emulator";

// TODO: Update contract address
const contractAddr = network === "testnet" ? "0xb86f928a1fa7798e" : "0x2";

export default {
  title: "TokenList",
  titleDesc: "FungibleToken List #onFlow",
  description:
    "TokenList is a platform for registering Fungible Tokens on Flow Blockchain. It supports permissionless on-chain registration of any Flow FT with on-chain MetadataViews and provides an API endpoint to expose the Uniswap standard token list JSON file.",
  author: "FIXeS World",
  version: "0.1.0",
  url: import.meta.env.SITE ?? "http://localhost:4321",
  icon:
    import.meta.env.PUBLIC_ICON ?? "https://fixes.world/apple-touch-icon.png",
  banner: import.meta.env.PUBLIC_BANNER ?? "https://i.imgur.com/Wdy3GG7.jpg",
  linktree: import.meta.env.PUBLIC_LINKTREE ?? "https://linktr.ee/fixes.world",
  twitter: import.meta.env.PUBLIC_TWITTER ?? "https://x.com/fixesWorld",
  github: import.meta.env.PUBLIC_GITHUB ?? "https://github.com/fixes-world",
  discord: import.meta.env.PUBLIC_DISCORD ?? "https://discord.gg/flow",
  // API Keys
  nftStorageKey: import.meta.env.PUBLIC_NFTSTORAGE_KEY ?? undefined,
  // Blockchain info
  network: network,
  contractAddr: contractAddr,
  walletConnectProjectId:
    import.meta.env.PUBLIC_WALLET_CONNECT_PROJECT_ID ??
    "779bb5171b7c2aea7b27968a964ce083",
  bloctoProjectId:
    import.meta.env.PUBLIC_BLOCTO_PROJECT_ID ??
    "fcc27ab8-bc8a-4cb5-87ce-3b9c2cc644e9",
};
