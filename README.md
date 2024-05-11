# Token List - A on-chain list of Flow Standard Fungible Tokens (FTs)

This repo contains all contract and frontend code.

## 🌐 Websites

- **Testnet:** <https://testnet-token-list.fixes.world/>  
- **Mainnet:** <https://token-list.fixes.world/>

## 🔗 Contract Addresses

| Contract Name | Testnet | Mainnet |
| :------------ | :------ | :------ |
| BlackHole | [0xad26718c4b6b921b](https://contractbrowser.com/A.ad26718c4b6b921b.BlackHole) | [0x4396883a58c3a2d1](https://contractbrowser.com/A.4396883a58c3a2d1.BlackHole) |
| FTViewUtils | [0xb86f928a1fa7798e](https://contractbrowser.com/A.b86f928a1fa7798e.FTViewUtils) | [0x15a918087ab12d86](https://contractbrowser.com/A.15a918087ab12d86.FTViewUtils) |
| ViewResolvers | [0xb86f928a1fa7798e](https://contractbrowser.com/A.b86f928a1fa7798e.ViewResolvers) | [0x15a918087ab12d86](https://contractbrowser.com/A.15a918087ab12d86.ViewResolvers) |
| TokenList | [0xb86f928a1fa7798e](https://contractbrowser.com/A.b86f928a1fa7798e.TokenList) | [0x15a918087ab12d86](https://contractbrowser.com/A.15a918087ab12d86.TokenList) |

## 📦 Special Contract: BlackHole

> **BlackHole** is a special contract that can receive any fungible token and burn it.

the Token Vault can be permanently unusable without being destroyed.  
It will essentially be sent to a black hole address.

You just need one line of code to execute the action:

```cadence
execute {
  BlackHole.vanish(<- tokenVault)
}
```

## 📄 Documentation

Please visit [https://docs.fixes.world](https://docs.fixes.world/concepts/token-list) for more information.
