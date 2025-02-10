import * as fcl from "@onflow/fcl";
import { init } from "@onflow/fcl-wc";
import * as uuid from "uuid";
import type { Account, TransactionStatus } from "@onflow/typedefs";
import appInfo from "../config/info";

export type NetworkType = "mainnet" | "testnet" | "emulator";

let isGloballyInited = false;
let isGloballyWalletConnectInit = false;
let globallyPromise: Promise<unknown> | null = null;

export class FlowService {
  public readonly network: NetworkType;
  private readonly flowJSON: object;

  /**
   * Initialize the Flow SDK
   */
  constructor(flowJSON: object) {
    this.network = (appInfo.network as NetworkType) ?? "emulator";
    this.flowJSON = flowJSON;
  }

  async onModuleInit() {
    if (isGloballyInited) return;

    const cfg = fcl.config();
    await cfg.put("flow.network", this.network);
    await cfg.put("fcl.limit", 9999);
    await cfg.put("app.detail.title", appInfo.title);
    await cfg.put("app.detail.icon", appInfo.icon);
    await cfg.put("app.detail.id", appInfo.bloctoProjectId);
    await cfg.put("fcl.accountProof.resolver", async () => {
      const bytesA = uuid.parse(uuid.v1()) as Uint8Array;
      const bytesB = uuid.parse(uuid.v4()) as Uint8Array;
      // merged hex string with 32 bytes
      const nonce = [...bytesA]
        .concat([...bytesB])
        .map((v: number) => v.toString(16).padStart(2, "0"))
        .join("");
      return Promise.resolve({
        appIdentifier: appInfo.title,
        nonce,
        datetime: new Date(),
      });
    });
    await cfg.put("service.OpenID.scopes", "email email_verified name zoneinfo");
    switch (this.network) {
      case "mainnet":
        await cfg.put(
          "accessNode.api",
          import.meta.env.PUBLIC_MAINNET_ENDPOINT ?? "https://mainnet.onflow.org",
        );
        await cfg.put("discovery.wallet", "https://fcl-discovery.onflow.org/authn");
        await cfg.put("discovery.authn.endpoint", "https://fcl-discovery.onflow.org/api/authn");
        break;
      case "testnet":
        await cfg.put("accessNode.api", "https://testnet.onflow.org");
        await cfg.put("discovery.wallet", "https://fcl-discovery.onflow.org/testnet/authn");
        await cfg.put(
          "discovery.authn.endpoint",
          "https://fcl-discovery.onflow.org/api/testnet/authn",
        );
        break;
      case "emulator":
        await cfg.put("accessNode.api", "http://localhost:8888");
        await cfg.put("discovery.wallet", "http://localhost:8701/fcl/authn");
        break;
      default:
        throw new Error(`Unknown network: ${String(this.network)}`);
    }

    // Load Flow JSON
    await cfg.load({ flowJSON: this.flowJSON });

    isGloballyInited = true;
  }

  /**
   * Check if the WalletConnect is initialized
   */
  get isWalletConnectInited() {
    return isGloballyWalletConnectInit;
  }

  /**
   * Ensure the WalletConnect is initialized
   */
  async ensureWalletConnect() {
    if (isGloballyWalletConnectInit) return;
    // Support WalletConnect
    // https://developers.flow.com/tools/clients/fcl-js/wallet-connect
    if (this.network === "testnet" || this.network === "mainnet") {
      const { FclWcServicePlugin } = await init({
        projectId: appInfo.walletConnectProjectId,
        metadata: {
          name: appInfo.title,
          description: appInfo.description,
          url: appInfo.url,
          icons: [appInfo.icon],
        },
        includeBaseWC: false,
        wallets: [], // no idea
        wcRequestHook: null, // no fucking idea
        pairingModalOverride: null, // ???????
      });
      fcl.pluginRegistry.add(FclWcServicePlugin);
    }
    isGloballyWalletConnectInit = true;
  }

  /**
   * Ensure the Flow SDK is initialized
   */
  private async ensureInited() {
    if (isGloballyInited) return;
    if (!globallyPromise) {
      globallyPromise = this.onModuleInit();
    }
    return await globallyPromise;
  }

  /**
   * Authenticate for current user
   */
  async authenticate() {
    await this.ensureInited();
    fcl.authenticate();
  }

  /**
   * Logout
   */
  unauthenticate() {
    fcl.unauthenticate();
  }

  /**
   * Get the current logged-in
   */
  get currentUser() {
    return fcl.currentUser;
  }

  /**
   * Get the client authz
   */
  get clientAuthz() {
    return fcl.authz;
  }

  /**
   * Get account information
   */
  async getAccount(addr: string): Promise<Account> {
    await this.ensureInited();
    return await fcl.send([fcl.getAccount(addr)]).then(fcl.decode);
  }

  /**
   * General method of sending transaction
   */
  async sendTransaction(
    code: string,
    args: fcl.ArgumentFunction,
    mainAuthz?: fcl.FclAuthorization,
    extraAuthz?: fcl.FclAuthorization[],
  ): Promise<string> {
    await this.ensureInited();
    try {
      let transactionId: string;
      if (typeof mainAuthz !== "undefined") {
        transactionId = await fcl.mutate({
          cadence: code,
          args: args,
          proposer: mainAuthz,
          payer: mainAuthz,
          authorizations:
            (extraAuthz?.length ?? 0) === 0 ? [mainAuthz] : [mainAuthz, ...extraAuthz!],
        });
      } else {
        transactionId = await fcl.mutate({
          cadence: code,
          args: args,
        });
      }
      console.log("Tx Sent:", transactionId);
      return transactionId;
    } catch (e: any) {
      console.error("Tx Error:", e);
      throw e;
    }
  }

  /**
   * Send transaction with single authorization
   * @param transactionId
   * @param onSealed
   * @param onStatusUpdated
   * @param onErrorOccured
   */
  async watchTransaction(
    transactionId: string,
    onStatusUpdated: (status: TransactionStatus) => undefined,
    onSealed: (txId: string, status: TransactionStatus, errorMsg?: string) => undefined,
    onErrorOccured?: (errorMsg: string) => undefined,
  ) {
    await this.ensureInited();
    const unsub = await fcl.tx(transactionId).subscribe((res) => {
      if (onStatusUpdated) {
        onStatusUpdated(res);
      }

      if (res.status === 4) {
        // sealed
        unsub();
        if (res.errorMessage && onErrorOccured) {
          onErrorOccured(res.errorMessage);
        }
        // on sealed callback
        if (typeof onSealed === "function") {
          onSealed(transactionId, res, res.errorMessage ? res.errorMessage : undefined);
        }
      }
    });
    return unsub;
  }

  /**
   * Get transaction status
   */
  async getTransactionStatus(transactionId: string): Promise<TransactionStatus> {
    await this.ensureInited();
    return await fcl.tx(transactionId).onceExecuted();
  }

  /**
   * Get chain id
   */
  async getChainId() {
    await this.ensureInited();
    return await fcl.getChainId();
  }

  /**
   * listen to the transaction status: once sealed
   */
  async onceTransactionSealed(transactionId: string): Promise<TransactionStatus> {
    await this.ensureInited();
    return await fcl.tx(transactionId).onceSealed();
  }

  /**
   * Get block object
   * @param blockId
   */
  async getBlockHeaderObject(blockId: string): Promise<fcl.BlockHeaderObject> {
    await this.ensureInited();
    return await fcl
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
      .send([fcl.getBlockHeader(), fcl.atBlockId(blockId)])
      .then(fcl.decode);
  }

  /**
   * Send script
   */
  async executeScript<T>(code: string, args: fcl.ArgumentFunction, defaultValue: T): Promise<T> {
    await this.ensureInited();
    try {
      const queryResult = await fcl.query({
        cadence: code,
        args,
      });
      return (queryResult as T) ?? defaultValue;
    } catch (e) {
      console.error(e);
      return defaultValue;
    }
  }

  /**
   * Verify account proof
   */
  async verifyAccountProof(appIdentifier: string, opt: fcl.AccountProofData): Promise<boolean> {
    if (this.network === "emulator") return true;
    await this.ensureInited();

    return await fcl.AppUtils.verifyAccountProof(
      appIdentifier,
      {
        address: opt.address,
        nonce: opt.nonce,
        signatures: opt.signatures.map((one) => ({
          f_type: "CompositeSignature",
          f_vsn: "1.0.0",
          keyId: one.keyId,
          addr: one.addr,
          signature: one.signature,
        })),
      },
      {
        // use blocto adddres to avoid self-custodian
        // https://docs.blocto.app/blocto-sdk/javascript-sdk/flow/account-proof
        fclCryptoContract: this.network === "mainnet" ? "0xdb6b70764af4ff68" : "0x5b250a8a85b44a67",
      },
    );
  }
}
