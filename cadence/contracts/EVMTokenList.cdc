/**
> Author: Fixes World <https://fixes.world/>

# EVMTokenList - A on-chain list of all the EVM compatible tokens on the Flow blockchain.

This contract is a list of all the bridged ERC20 / ERC721 tokens for Flow(EVM) on the Flow blockchain.

*/
import "FungibleToken"
import "MetadataViews"
import "ViewResolver"
import "FungibleTokenMetadataViews"
// EVM and VMBridge related contracts
import "EVM"
import "FlowEVMBridge"
import "FlowEVMBridgeConfig"
import "FlowEVMBridgeUtils"
// TokenList contract
import "TokenList"
import "NFTList"
import "FTViewUtils"
import "NFTViewUtils"

/// The EVMTokenList contract
/// The List only contains the basic EVM Address information for the registered tokens.
///
access(all) contract EVMTokenList {
    /* --- Entitlement --- */

    access(all) entitlement SuperAdmin

    /* --- Events --- */

    /// Event emitted when the contract is initialized
    access(all) event ContractInitialized()

    /// Event emitted when a new EVM compatible token is registered
    access(all) event EVMBridgedAssetRegistered(
        _ evmAddress: EVM.EVMAddress,
        _ bridgedType: Type,
        _ isERC721: Bool,
    )
    /// Event emitted when a EVM compatible token is removed
    access(all) event EVMBridgedAssetRemoved(
        _ evmAddress: EVM.EVMAddress,
        _ bridgedType: Type,
        _ isERC721: Bool,
    )
        /* --- Variable, Enums and Structs --- */

    access(all) let registryStoragePath: StoragePath
    access(all) let registryPublicPath: PublicPath

    /* --- Interfaces & Resources --- */

    /// Interface for the Token List Viewer
    ///
    access(all) resource interface IListViewer {
        /// Get the total number of registered ERC20 tokens
        access(all)
        view fun getERC20Amount(): Int
        /// Get the ERC20 addresses with pagination
        /// The method will copy the addresses to the result array
        access(all)
        fun getERC20Addresses(_ page: Int, _ size: Int): [EVM.EVMAddress]
        /// Get the ERC20 addresses by for each
        /// The method will call the function for each address
        access(all)
        fun forEachERC20Address(_ f: fun (EVM.EVMAddress): Bool)
        /// Borrow the Bridged Token's TokenList Entry
        access(all)
        view fun borrowFungibleTokenEntry(_ evmContractAddressHex: String): &{TokenList.FTEntryInterface}?

        /// Get the total number of registered ERC721 tokens
        access(all)
        view fun getERC721Amount(): Int
        /// Get the ERC721 addresses with pagination
        /// The method will copy the addresses to the result array
        access(all)
        fun getERC721Addresses(_ page: Int, _ size: Int): [EVM.EVMAddress]
        /// Get the ERC721 addresses by for each
        /// The method will call the function for each address
        access(all)
        fun forEachERC721Address(_ f: fun (EVM.EVMAddress): Bool)
        /// Borrow the Bridged Token's TokenList Entry
        access(all)
        view fun borrowNonFungibleTokenEntry(_ evmContractAddressHex: String): &NFTList.NFTCollectionEntry?
    }

    /// Resource for the Token List Registry
    ///
    access(all) resource Registry: IListViewer {
        // NFT Type => NFT Collection Entry
        access(self)
        let regsiteredErc20s: {String: FTViewUtils.FTIdentity}
        access(self)
        let regsiteredErc721s: {String: NFTViewUtils.NFTIdentity}

        init() {
            self.regsiteredErc20s = {}
            self.regsiteredErc721s = {}
        }

        /* --- Implement the IListViewer interface ---  */

        /// Get the total number of registered ERC20 tokens
        access(all)
        view fun getERC20Amount(): Int {
            return self.regsiteredErc20s.keys.length
        }

        /// Get the ERC20 addresses with pagination
        /// The method will copy the addresses to the result array
        access(all)
        fun getERC20Addresses(_ page: Int, _ size: Int): [EVM.EVMAddress] {
            pre {
                page >= 0: "Invalid page"
                size > 0: "Invalid size"
            }
            let max = self.getERC20Amount()
            let start = page * size
            if start > max {
                return []
            }
            var end = start + size
            if end > max {
                end = max
            }
            let arr = self.regsiteredErc20s.keys.slice(from: start, upTo: end)
            return arr.map(fun (key: String): EVM.EVMAddress { return EVM.addressFromString(key) })
        }

        /// Get the ERC20 addresses by for each
        /// The method will call the function for each address
        access(all)
        fun forEachERC20Address(_ f: fun (EVM.EVMAddress): Bool) {
            self.regsiteredErc20s.forEachKey(fun (key: String): Bool {
                return f(EVM.addressFromString(key))
            })
        }

        /// Borrow the Bridged Token's TokenList Entry
        access(all)
        view fun borrowFungibleTokenEntry(_ evmContractAddressHex: String): &{TokenList.FTEntryInterface}? {
            if let item = self.regsiteredErc20s[evmContractAddressHex] {
                let ftRegistry = TokenList.borrowRegistry()
                let ftType = item.buildType()
                return ftRegistry.borrowFungibleTokenEntry(ftType)
            }
            return nil
        }

        /// Get the total number of registered ERC721 tokens
        access(all)
        view fun getERC721Amount(): Int {
            return self.regsiteredErc721s.keys.length
        }

        /// Get the ERC721 addresses with pagination
        /// The method will copy the addresses to the result array
        access(all)
        fun getERC721Addresses(_ page: Int, _ size: Int): [EVM.EVMAddress] {
            pre {
                page >= 0: "Invalid page"
                size > 0: "Invalid size"
            }
            let max = self.getERC721Amount()
            let start = page * size
            if start > max {
                return []
            }
            var end = start + size
            if end > max {
                end = max
            }
            let arr = self.regsiteredErc721s.keys.slice(from: start, upTo: end)
            return arr.map(fun (key: String): EVM.EVMAddress { return EVM.addressFromString(key) })
        }

        /// Get the ERC721 addresses by for each
        /// The method will call the function for each address
        access(all)
        fun forEachERC721Address(_ f: fun (EVM.EVMAddress): Bool) {
            self.regsiteredErc721s.forEachKey(fun (key: String): Bool {
                return f(EVM.addressFromString(key))
            })
        }

        /// Borrow the Bridged Token's TokenList Entry
        access(all)
        view fun borrowNonFungibleTokenEntry(_ evmContractAddressHex: String): &NFTList.NFTCollectionEntry? {
            if let item = self.regsiteredErc721s[evmContractAddressHex] {
                let nftRegistry = NFTList.borrowRegistry()
                let nftType = item.buildNFTType()
                return nftRegistry.borrowNFTEntry(nftType)
            }
            return nil
        }

        /* --- Internal functions --- */
    }

    /* --- Public functions --- */

    /// Borrow the public capability of Token List Registry
    ///
    access(all)
    view fun borrowRegistry(): &Registry {
        return getAccount(self.account.address)
            .capabilities.get<&Registry>(self.registryPublicPath)
            .borrow()
            ?? panic("Could not borrow the Registry reference")
    }

    /// The prefix for the paths
    ///
    access(all)
    view fun getPathPrefix(): String {
        return "EVMTokenList_".concat(self.account.address.toString()).concat("_")
    }

    /// Initialize the contract
    init() {
        // Identifiers
        let identifier = NFTList.getPathPrefix()
        self.registryStoragePath = StoragePath(identifier: identifier.concat("_Registry"))!
        self.registryPublicPath = PublicPath(identifier: identifier.concat("_Registry"))!

        // Create the Token List Registry
        let registry <- create Registry()
        self.account.storage.save(<- registry, to: self.registryStoragePath)
        // link the public capability
        let cap = self.account.capabilities
            .storage.issue<&Registry>(self.registryStoragePath)
        self.account.capabilities.publish(cap, at: self.registryPublicPath)

        // Emit the initialized event
        emit ContractInitialized()
    }
}
