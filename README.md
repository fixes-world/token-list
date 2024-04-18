# Token List - A on-chain list of Flow Standard Fungible Tokens (FTs)

This repo contains all contract and frontend code.

## 🔗 Contract Addresses

| Contract Name | Testnet | Mainnet |
| :------------ | :------ | :------ |
| BlackHole | [0xad26718c4b6b921b](https://contractbrowser.com/A.ad26718c4b6b921b.BlackHole) | [0x4396883a58c3a2d1](https://contractbrowser.com/A.4396883a58c3a2d1.BlackHole) |
| FTViewUtils | [0xb86f928a1fa7798e](https://contractbrowser.com/A.b86f928a1fa7798e.FTViewUtils) | TBD |
| ViewResolvers | [0xb86f928a1fa7798e](https://contractbrowser.com/A.b86f928a1fa7798e.ViewResolvers) | TBD |
| TokenList | [0xb86f928a1fa7798e](https://contractbrowser.com/A.b86f928a1fa7798e.TokenList) | TBD |

## 🚀 Project Structure

Inside of your Astro project, you'll see the following folders and files:

```text
/
├── cadence/
│   ├── contracts/
│   ├── transactions/
│   └── scripts/
├── public/
│   └── favicon.svg
├── src/
│   ├── components/
│   ├── layouts/
│   │   └── Layout.astro
│   └── pages/
│       └── index.astro
└── package.json
```

Astro looks for `.astro` or `.md` files in the `src/pages/` directory. Each page is exposed as a route based on its file name.

There's nothing special about `src/components/`, but that's where we like to put any Astro/React/Vue/Svelte/Preact components.

Any static assets, like images, can be placed in the `public/` directory.

## 🧞 Commands

All commands are run from the root of the project, from a terminal:

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Installs dependencies                            |
| `npm run dev`             | Starts local dev server at `localhost:4321`      |
| `npm run build`           | Build your production site to `./dist/`          |
| `npm run preview`         | Preview your build locally, before deploying     |
| `npm run astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `npm run astro -- --help` | Get help using the Astro CLI                     |
