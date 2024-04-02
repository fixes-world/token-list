/**
> Author: FIXeS World <https://fixes.world/>

# Token List - A on-chain list of Flow Standard Fungible Tokens (FTs).

This is the basic contract of the Token List.
It will be used to store the list of all the Flow Standard Fungible Tokens (FTs) that are available on the Flow blockchain.

*/
import "FungibleToken"
import "MetadataViews"
import "FungibleTokenMetadataViews"

/// Token List registry contract
///
access(all) contract TokenList {
    /* --- Events --- */

    /// Event emitted when the contract is initialized
    access(all) event ContractInitialized()

    /* --- Variable, Enums and Structs --- */

    access(all) let registryStoragePath: StoragePath
    access(all) let registryPublicPath: PublicPath

    /* --- Interfaces & Resources --- */

    /// Interface for the FT Entry
    ///
    access(all) resource interface FTEntryInterface {
        // ----- constants -----
        access(all)
        let address: Address
        access(all)
        let contractName: String
        // ----- View Methods -----
        /// Get the Fungible Token Symbol
        access(all) view
        fun getSymbol(): String
        /// Quick getter for the FT
        access(all) view
        fun getName(): String
        /// Get the display metadata of the FT
        access(all) view
        fun getDisplay(): FungibleTokenMetadataViews.FTDisplay
        /// Get the vault info the FT
        access(all) view
        fun getVaultData(): FungibleTokenMetadataViews.FTVaultData
        // ----- View Methods -----
        access(all)
        fun createEmptyVault(): @FungibleToken.Vault
    }

    /// Resource for the Fungible Token Entry
    ///
    access(all) resource FungibleTokenEntry: FTEntryInterface {
        access(all)
        let address: Address
        access(all)
        let contractName: String
        access(self)
        let viewResolver: @{MetadataViews.Resolver}

        init(
            _ ftAddress: Address,
            _ ftContractName: String,
            _ ftViewResolver: @{MetadataViews.Resolver}
        ) {
            self.address = ftAddress
            self.contractName = ftContractName
            self.viewResolver <- ftViewResolver
            // ensure ftView exists
            self.getDisplay()
            self.getVaultData()
        }

        /// @deprecated in Cadence 1.0
        destroy() {
            destroy self.viewResolver
        }

        // ----- Implementing the FTMetadataInterface -----

        /// Get the display metadata of the FT
        ///
        access(all) view
        fun getDisplay(): FungibleTokenMetadataViews.FTDisplay {
            return FungibleTokenMetadataViews.getFTDisplay(self.borrowViewResolver())
                ?? panic("FTDisplay not found in the metadata")
        }

        /// Get the vault data of the FT
        ///
        access(all) view
        fun getVaultData(): FungibleTokenMetadataViews.FTVaultData {
            return FungibleTokenMetadataViews.getFTVaultData(self.borrowViewResolver())
                ?? panic("FTVaultData not found in the metadata")
        }

        /// Get the Fungible Token Symbol
        ///
        access(all) view
        fun getSymbol(): String {
            return self.getDisplay().symbol
        }

        /// Quick getter for the FT
        ///
        access(all) view
        fun getName(): String {
            return self.getDisplay().name
        }

        /// Create an empty vault for the FT
        ///
        access(all)
        fun createEmptyVault(): @FungibleToken.Vault {
            let ftContract = self.borrowFungibleTokenContract()
            // need to update for the FungibleToken(v2) contract
            return <- ftContract.createEmptyVault()
        }

        // ----- Internal Methods -----
        /// Borrow the View Resolver
        ///
        access(contract)
        fun borrowViewResolver(): &{MetadataViews.Resolver} {
            return &self.viewResolver as &{MetadataViews.Resolver}
        }

        /// Borrow the Fungible Token Contract
        ///
        access(contract)
        fun borrowFungibleTokenContract(): &FungibleToken {
            return getAccount(self.address)
                .contracts.borrow<&FungibleToken>(name: self.contractName)
                ?? panic("Could not borrow the FungibleToken contract reference")
        }
    }

    /// Interface for the Token List Viewer
    ///
    access(all) resource interface TokenListViewer {

    }

    /// Interface for the Token List Register
    ///
    access(all) resource interface TokenListRegister {

    }

    /// The Token List Registry
    ///
    access(all) resource TokenListRegistry: TokenListViewer, TokenListRegister {

    }

    /* --- Methods --- */

    access(all) view
    fun buildType(_ address: Address, _ contractName: String): Type? {
        let addrStr = address.toString()
        let addrStrNo0x = addrStr.slice(from: 2, upTo: addrStr.length)
        return CompositeType("A.".concat(addrStrNo0x).concat(".").concat(contractName))
    }

    init() {
        // Identifiers
        let identifier = "TokenList_".concat(self.account.address.toString())
        self.registryStoragePath = StoragePath(identifier: identifier.concat("_Registry"))!
        self.registryPublicPath = PublicPath(identifier: identifier.concat("_Registry"))!

        emit ContractInitialized()
    }
}
