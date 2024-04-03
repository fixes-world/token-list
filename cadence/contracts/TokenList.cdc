/**
> Author: FIXeS World <https://fixes.world/>

# Token List - A on-chain list of Flow Standard Fungible Tokens (FTs).

This is the basic contract of the Token List.
It will be used to store the list of all the Flow Standard Fungible Tokens (FTs) that are available on the Flow blockchain.

*/
import "FungibleToken"
import "MetadataViews"
import "FungibleTokenMetadataViews"
import "FTViewUtils"
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
    /// Event emitted when a new Fungible Token is reviewed
    access(all) event RegisteryReviewerWhitelisted(
        _ address: Address,
        _ value: Bool
    )

    /* --- Variable, Enums and Structs --- */

    access(all) let registryStoragePath: StoragePath
    access(all) let registryPublicPath: PublicPath
    access(all) let reviewerStoragePath: StoragePath
    access(all) let reviewerPublicPath: PublicPath

    /* --- Interfaces & Resources --- */

    /// Interface for the FT Entry
    ///
    access(all) resource interface FTEntryInterface {
        // ----- View Methods -----
        access(all) view
        fun getIdentity(): FTViewUtils.FTIdentity
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
        let identity: FTViewUtils.FTIdentity
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
            self.identity = FTViewUtils.FTIdentity(ftAddress, ftContractName)
            self.reviewers = {}
            if viewResolver == nil && FTViewResolvers.borrowContractViewResolver(ftAddress, ftContractName) != nil {
                // If viewResolver is not provided, then create one using the FTViewResolvers
                self.viewResolver <- FTViewResolvers.createContractViewResolver(address: ftAddress, contractName: ftContractName)
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

        /// Get the Fungible Token Identity
        ///
        access(all) view
        fun getIdentity(): FTViewUtils.FTIdentity {
            return self.identity
        }

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
            return self.identity.buildType()
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
            return self.identity.borrowFungibleTokenContract()
        }
    }

    /// The enum for the Evaluation
    ///
    access(all) enum Evaluation: UInt8 {
        access(all) case UNVERIFIED
        access(all) case PENDING
        access(all) case VERIFIED
        access(all) case FEATURED
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

    /// Interface for the Fungible Token Reviewer
    ///
    access(all) resource interface FungibleTokenReviewerInterface {

    }

    /// Maintainer interface for the Fungible Token Reviewer
    ///
    access(all) resource interface FungibleTokenReviewerMaintainer {

    }

    /// The resource for the FT Reviewer
    ///
    access(all) resource FungibleTokenReviewer: FungibleTokenReviewerMaintainer, FungibleTokenReviewerInterface, MetadataViews.ResolverCollection {
        access(self)
        let storedDatas: @{Type: FTViewUtils.EditableFTView}
        access(self)
        let idMapping: {UInt64: Type}

        init() {
            self.idMapping = {}
            self.storedDatas <- {}
        }

        /// @deprecated in Cadence 1.0
        destroy() {
            destroy self.storedDatas
        }

        // --- Implement the FungibleTokenReviewerInterface ---

        // --- Implement the MetadataViews.ResolverCollection ---

        /// Get the IDs of the view resolvers
        ///
        access(all) view
        fun getIDs(): [UInt64] {
            return self.idMapping.keys
        }

        /// Borrow the view resolver
        /// TODO: Update after Standard V2 is released
        ///
        access(all) view
        fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            var ret: &{MetadataViews.Resolver}? = nil
            if let tokenType = self.idMapping[id] {
                ret = self.borrowEditableFTView(tokenType)
            }
            return ret ?? panic("Failed to borrow the view resolver")
        }

        // --- Internal Methods ---

        /// Borrow the Editable FT View
        ///
        access(self)
        fun borrowEditableFTView(_ tokenType: Type): &FTViewUtils.EditableFTView? {
            return &self.storedDatas[tokenType] as &FTViewUtils.EditableFTView?
        }

        /// Borrow the Registry
        ///
        access(self)
        fun borrowRegistry(): &TokenListRegistry{TokenListViewer, TokenListRegister} {
            return TokenList.borrowRegistry()
                .borrowWritableRegistry(self.borrowSelf())
                ?? panic("Could not borrow the TokenListRegistry reference")
        }

        /// Borrow the self reference
        ///
        access(self)
        fun borrowSelf(): &FungibleTokenReviewer {
            return &self as &FungibleTokenReviewer
        }
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
        // --- Read Methods: for Reviewer ---
        /// check if the reviewer is whitelisted
        access(all) view
        fun isWhitelistedReviewer(_ reviewer: &FungibleTokenReviewer): Bool
        /// Borrow the writable registry
        access(all)
        fun borrowWritableRegistry(_ reviewer: &FungibleTokenReviewer): &TokenListRegistry{TokenListViewer, TokenListRegister}?
        // --- Write Methods ---
        /// Register a new standard Fungible Token Entry to the registry
        access(contract)
        fun registerStandardFungibleToken(_ ftAddress: Address, _ ftContractName: String)
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
        // Whitelisted Reviewers
        access(self)
        let whitelisted: {Address: Bool}
        // FT Entry ID => FT Type
        access(self)
        let entriesIdMapping: {UInt64: Type}
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
            self.whitelisted = {}
            self.entriesIdMapping = {}
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
            pre {
                page >= 0: "Invalid page"
                size > 0: "Invalid size"
            }
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
                    return FTViewUtils.buildFTVaultType(address, contractName)
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

        // ----- Methods: Register -----

        /// check if the reviewer is whitelisted
        ///
        access(all) view
        fun isWhitelistedReviewer(_ reviewer: &FungibleTokenReviewer): Bool {
            if let reviewerAddr = reviewer.owner?.address {
                return self.whitelisted[reviewerAddr] == true
            }
            return false
        }

        /// Borrow the writable registry
        ///
        access(all)
        fun borrowWritableRegistry(_ reviewer: &FungibleTokenReviewer): &TokenListRegistry{TokenListViewer, TokenListRegister}? {
            if self.isWhitelistedReviewer(reviewer) {
                return &self as &TokenListRegistry{TokenListViewer, TokenListRegister}
            }
            return nil
        }

        // ----- Write Methods -----

        /// Register a new standard Fungible Token Entry to the registry
        ///
        access(contract)
        fun registerStandardFungibleToken(_ ftAddress: Address, _ ftContractName: String) {
            self.registerFungibleToken(
                // Use the default view resolver
                <- create FungibleTokenEntry(ftAddress, ftContractName, nil)
            )
        }

        /// Add a new Fungible Token Entry to the registry
        /// TODO: Change to entitlement in Cadence 1.0
        ///
        access(all)
        fun registerFungibleToken(_ ftEntry: @FungibleTokenEntry) {
            pre {
                self.entries[ftEntry.getTokenType()] == nil:
                    "FungibleToken Entry already exists in the registry"
                self.entriesIdMapping[ftEntry.uuid] == nil:
                    "FungibleToken Entry ID already exists in the registry"
            }
            let tokenType = ftEntry.getTokenType()
            self.entries[tokenType] <-! ftEntry

            let ref = self.borrowFTEntryRef(tokenType)
            // Add the ID mapping
            self.entriesIdMapping[ref.uuid] = tokenType
            // Add the address mapping
            if let addrRef = self.borrowAddressContractsRef(ref.identity.address) {
                addrRef.append(ref.identity.contractName)
            } else {
                self.addressMapping[ref.identity.address] = [ref.identity.contractName]
            }

            // Add the symbol mapping
            if let symbolRef = self.borrowSymbolTypeRef(ref.getSymbol()) {
                symbolRef.append(tokenType)
            } else {
                self.symbolMapping[ref.getSymbol()] = [tokenType]
            }

            // emit the event
            emit FungibleTokenRegistered(
                ref.identity.address,
                ref.identity.contractName,
                ref.getSymbol(),
                ref.getName(),
                tokenType
            )
        }

        // ----- Write Methods: Private -----

        /// Update the whitelist
        ///
        access(all)
        fun updateWhitelist(_ addr: Address, _ value: Bool) {
            self.whitelisted[addr] = value

            /// Emit the event
            emit RegisteryReviewerWhitelisted(addr, value)
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

    /// Create a new Fungible Token Reviewer
    ///
    access(all)
    fun createFungibleTokenReviewer(): @FungibleTokenReviewer {
        return <- create FungibleTokenReviewer()
    }

    /// Borrow the public capability of the Fungible Token Reviewer
    ///
    access(all)
    fun borrowReviewerPublic(_ addr: Address): &FungibleTokenReviewer{FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}? {
        return getAccount(addr)
            .getCapability<&FungibleTokenReviewer{FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
                self.reviewerPublicPath
            )
            .borrow()
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

    /// Check if the Fungible Token is registered
    ///
    access(all) view
    fun isFungibleTokenRegistered(_ address: Address, _ contractName: String): Bool {
        let registry = self.borrowRegistry()
        if let ftType = FTViewUtils.buildFTVaultType(address, contractName) {
            return registry.borrowFungibleTokenEntry(ftType) != nil
        }
        return false
    }

    /// Register a new Fungible Token
    ///
    access(all)
    fun registerStandardFungibleToken(_ ftAddress: Address, _ ftContractName: String) {
        pre {
            self.isFungibleTokenRegistered(ftAddress, ftContractName) == false: "Fungible Token already registered"
        }
        let registry = self.borrowRegistry()
        registry.registerStandardFungibleToken(ftAddress, ftContractName)
    }

    init() {
        // Identifiers
        let identifier = "TokenList_".concat(self.account.address.toString())
        self.registryStoragePath = StoragePath(identifier: identifier.concat("_Registry"))!
        self.registryPublicPath = PublicPath(identifier: identifier.concat("_Registry"))!

        self.reviewerStoragePath = StoragePath(identifier: identifier.concat("_Reviewer"))!
        self.reviewerPublicPath = PublicPath(identifier: identifier.concat("_Reviewer"))!

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
