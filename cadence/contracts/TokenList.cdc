/**
> Author: FIXeS World <https://fixes.world/>

# Token List - A on-chain list of Flow Standard Fungible Tokens (FTs).

This is the basic contract of the Token List.
It will be used to store the list of all the Flow Standard Fungible Tokens (FTs) that are available on the Flow blockchain.

*/
import "FungibleToken"
import "MetadataViews"
import "FungibleTokenMetadataViews"
import "FTViewResolvers"

/// Token List registry contract
///
access(all) contract TokenList {
    /* --- Events --- */

    /// Event emitted when the contract is initialized
    access(all) event ContractInitialized()
    /// Event emitted when a new Fungible Token is registered
    access(all) event FungibleTokenRegistered(
        _ address: Address,
        _ contractName: String,
        _ symbol: String,
        _ name: String,
        _ type: Type,
    )

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
        /// Get the FT Type
        access(all) view
        fun getTokenType(): Type
        /// Get the display metadata of the FT
        access(all) view
        fun getDisplay(): FungibleTokenMetadataViews.FTDisplay
        /// Get the vault info the FT
        access(all) view
        fun getVaultData(): FungibleTokenMetadataViews.FTVaultData
        /// Check if the Fungible Token is reviewed by some one
        access(all) view
        fun isReviewedBy(_ reviewerId: UInt64): Bool
        // ----- View Methods -----
        /// Create an empty vault for the FT
        access(all)
        fun createEmptyVault(): @FungibleToken.Vault
        // ----- Internal Methods: Used by Reviewer -----
        access(contract)
        fun addRewiew(_ reviewerId: UInt64, _ review: FTReview)
        access(contract)
        fun borrowReviewRef(_ reviewerId: UInt64): &FTReview?
    }

    /// Resource for the Fungible Token Entry
    ///
    access(all) resource FungibleTokenEntry: FTEntryInterface {
        access(all)
        let address: Address
        access(all)
        let contractName: String
        // ReviewerId => FTReview
        access(self)
        let reviewers: {UInt64: FTReview}
        // view resolver
        access(all)
        var viewResolver: @{MetadataViews.Resolver}

        init(
            _ ftAddress: Address,
            _ ftContractName: String,
            _ viewResolver: @{MetadataViews.Resolver}?
        ) {
            self.address = ftAddress
            self.contractName = ftContractName
            self.reviewers = {}
            if viewResolver == nil && FTViewResolvers.borrowContractViewResolver(self.address, self.contractName) != nil {
                // If viewResolver is not provided, then create one using the FTViewResolvers
                self.viewResolver <- FTViewResolvers.createContractViewResolver(address: self.address, contractName: self.contractName)
                destroy viewResolver
            } else {
                // If viewResolver is not provided, then panic
                self.viewResolver <- viewResolver ?? panic("View Resolver not provided")
            }
            // ensure ftView exists
            self.getDisplay()
            self.getVaultData()
        }

        destroy() {
            destroy self.viewResolver
        }

        // ----- Implementing the FTMetadataInterface -----

        /// Check if the Fungible Token is reviewed by some one
        ///
        access(all) view
        fun isReviewedBy(_ reviewerId: UInt64): Bool {
            return self.reviewers[reviewerId] != nil
        }

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

        /// Get the FT Type
        access(all) view
        fun getTokenType(): Type {
            return TokenList.buildFTVaultType(self.address, self.contractName)
                ?? panic("Could not build the FT Type")
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

        /// Add a new review to the FT
        ///
        access(contract)
        fun addRewiew(_ reviewerId: UInt64, _ review: FTReview) {
            pre {
                self.reviewers[reviewerId] == nil:
                    "Reviewer already exists"
            }
            self.reviewers[reviewerId] = review
        }

        /// Borrow the review reference
        ///
        access(contract)
        fun borrowReviewRef(_ reviewerId: UInt64): &FTReview? {
            return &self.reviewers[reviewerId] as &FTReview?
        }

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

    /// The enum for the Evaluation
    ///
    access(all) enum Evaluation: UInt8 {
        case UNVERIFIED
        case PENDING
        case VERIFIED
        case FEATURED
    }

    /// The struct for the Review Comment
    ///
    access(all) struct ReviewComment {
        access(all)
        let comment: String
        access(all)
        let by: Address
        access(all)
        let at: UInt64

        init(_ comment: String, _ by: Address) {
            self.comment = comment
            self.by = by
            self.at = UInt64(getCurrentBlock().timestamp)
        }
    }

    /// The struct for the FT Review
    ///
    access(all) struct FTReview {
        access(all)
        let evalRank: Evaluation
        access(all)
        let comments: [ReviewComment]

        init(
            _ rank: Evaluation,
        ) {
            self.evalRank = rank
            self.comments = []
        }

        /// Add a new comment to the review
        ///
        access(all)
        fun addComment(_ comment: String, _ by: Address) {
            self.comments.append(ReviewComment(comment, by))
        }
    }

    /// The resource for the FT Reviewer
    ///
    access(all) resource FungibleTokenReviewer {
        // TODO
    }

    /// Interface for the Token List Viewer
    ///
    access(all) resource interface TokenListViewer {
        /// Get the amount of Fungible Token Entries
        access(all) view
        fun getFTEntriesAmount(): Int
        /// Get all the Fungible Token Entries
        access(all) view
        fun getAllFTEntries(): [Type]
        /// Get the Fungible Token Entry by the page and size
        access(all) view
        fun getFTEntries(_ page: Int, _ size: Int): [Type]
        /// Get the Fungible Token Entry by the address
        access(all) view
        fun getFTEntriesByAddress(_ address: Address): [Type]
        /// Get the Fungible Token Entry by the symbol
        access(all) view
        fun getFTEntriesBySymbol(_ symbol: String): [Type]
        /// Get the Fungible Token Entry by the type
        access(all)
        fun borrowFungibleTokenEntry(_ tokenType: Type): &FungibleTokenEntry{FTEntryInterface}?
        // --- Internal Methods ---
        access(contract)
        fun registerFungibleToken(_ ftEntry: @FungibleTokenEntry)
    }

    /// Interface for the Token List Register
    ///
    access(all) resource interface TokenListRegister {
        /// Add a new Fungible Token Entry to the registry
        /// TODO: Change to entitlement in Cadence 1.0
        access(all)
        fun registerFungibleToken(_ ftEntry: @FungibleTokenEntry)
    }

    /// The Token List Registry
    ///
    access(all) resource TokenListRegistry: TokenListViewer, TokenListRegister {
        // FT Type => FT Entry
        access(self)
        let entries: @{Type: FungibleTokenEntry}
        // Address => [FTContractName]
        access(self)
        let addressMapping: {Address: [String]}
        // Symbol => [FT Type]
        access(self)
        let symbolMapping: {String: [Type]}

        init() {
            self.entries <- {}
            self.addressMapping = {}
            self.symbolMapping = {}
        }

        // @deprecated in Cadence 1.0
        destroy() {
            destroy self.entries
        }

        // ----- Read Methods -----

        /// Get the amount of Fungible Token Entries
        access(all) view
        fun getFTEntriesAmount(): Int {
            return self.entries.keys.length
        }

        /// Get all the Fungible Token Entries
        ///
        access(all) view
        fun getAllFTEntries(): [Type] {
            return self.entries.keys
        }

        /// Get the Fungible Token Entry by the page and size
        ///
        access(all) view
        fun getFTEntries(_ page: Int, _ size: Int): [Type] {
            let max = self.getFTEntriesAmount()
            let start = page * size
            var end = start + size
            if end > max {
                end = max
            }
            return self.entries.keys.slice(from: start, upTo: end)
        }

        /// Get the Fungible Token Entry by the address
        ///
        access(all) view
        fun getFTEntriesByAddress(_ address: Address): [Type] {
            if let contracts = self.borrowAddressContractsRef(address) {
                return contracts.map(fun(contractName: String): Type {
                    return TokenList.buildFTVaultType(address, contractName)
                        ?? panic("Could not build the FT Type")
                })
            }
            return []
        }

        /// Get the Fungible Token Entry by the symbol
        ///
        access(all) view
        fun getFTEntriesBySymbol(_ symbol: String): [Type] {
            if let types = self.borrowSymbolTypeRef(symbol) {
                return self.symbolMapping[symbol]!
            }
            return []
        }

        /// Get the Fungible Token Entry by the type
        access(all)
        fun borrowFungibleTokenEntry(_ tokenType: Type): &FungibleTokenEntry{FTEntryInterface}? {
            return &self.entries[tokenType] as &FungibleTokenEntry?
        }

        // ----- Write Methods -----

        /// Add a new Fungible Token Entry to the registry
        /// TODO: Change to entitlement in Cadence 1.0
        ///
        access(all)
        fun registerFungibleToken(_ ftEntry: @FungibleTokenEntry) {
            pre {
                self.entries[ftEntry.getTokenType()] == nil:
                    "FungibleToken Entry already exists in the registry"
            }
            let tokenType = ftEntry.getTokenType()
            self.entries[tokenType] <-! ftEntry

            let ref = self.borrowFTEntryRef(tokenType)
            // Add the address mapping
            if let addrRef = self.borrowAddressContractsRef(ref.address) {
                addrRef.append(ref.contractName)
            } else {
                self.addressMapping[ref.address] = [ref.contractName]
            }

            // Add the symbol mapping
            if let symbolRef = self.borrowSymbolTypeRef(ref.getSymbol()) {
                symbolRef.append(tokenType)
            } else {
                self.symbolMapping[ref.getSymbol()] = [tokenType]
            }

            // emit the event
            emit FungibleTokenRegistered(
                ref.address,
                ref.contractName,
                ref.getSymbol(),
                ref.getName(),
                tokenType
            )
        }

        // ----- Internal Methods -----

        /// Borrow the FT Entry Reference
        ///
        access(self)
        fun borrowFTEntryRef(_ tokenType: Type): &FungibleTokenEntry {
            return &self.entries[tokenType] as &FungibleTokenEntry?
                ?? panic("FungibleToken Entry not found in the registry")
        }

        access(self)
        fun borrowAddressContractsRef(_ addr: Address): &[String]? {
            return &self.addressMapping[addr] as &[String]?
        }

        access(self)
        fun borrowSymbolTypeRef(_ symbol: String): &[Type]? {
            return &self.symbolMapping[symbol] as &[Type]?
        }
    }

    /* --- Methods --- */

    /// Build the FT Vault Type
    ///
    access(all) view
    fun buildFTVaultType(_ address: Address, _ contractName: String): Type? {
        let addrStr = address.toString()
        let addrStrNo0x = addrStr.slice(from: 2, upTo: addrStr.length)
        return CompositeType("A.".concat(addrStrNo0x).concat(".").concat(contractName).concat(".Vault"))
    }

    /// Borrow the public capability of  Token List Registry
    ///
    access(all)
    fun borrowRegistry(): &TokenListRegistry{TokenListViewer} {
        return getAccount(self.account.address)
            .getCapability<&TokenListRegistry{TokenListViewer}>(self.registryPublicPath)
            .borrow()
            ?? panic("Could not borrow the TokenListRegistry reference")
    }

    /// Register a new Fungible Token
    ///
    access(all)
    fun registerStandardFungibleToken(_ ftAddress: Address, _ ftContractName: String) {
        pre {
            self.buildFTVaultType(ftAddress, ftContractName) != nil:
                "Invalid Fungible Token contract"
        }
        let registry = self.borrowRegistry()
        registry.registerFungibleToken(
            // Use the default view resolver
            <- create FungibleTokenEntry(ftAddress, ftContractName, nil)
        )
    }

    init() {
        // Identifiers
        let identifier = "TokenList_".concat(self.account.address.toString())
        self.registryStoragePath = StoragePath(identifier: identifier.concat("_Registry"))!
        self.registryPublicPath = PublicPath(identifier: identifier.concat("_Registry"))!

        // Create the Token List Registry
        let registry <- create TokenListRegistry()
        self.account.save(<- registry, to: self.registryStoragePath)

        // link the public capability
        // @deprecated in Cadence 1.0
        self.account.link<&TokenListRegistry{TokenListViewer}>(self.registryPublicPath, target: self.registryStoragePath)

        // Emit the initialized event
        emit ContractInitialized()
    }
}
