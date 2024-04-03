/**
> Author: FIXeS World <https://fixes.world/>

# Token List - A on-chain list of Flow Standard Fungible Tokens (FTs).

This is the basic contract of the Token List.
It will be used to store the list of all the Flow Standard Fungible Tokens (FTs) that are available on the Flow blockchain.

*/
import "FungibleToken"
import "MetadataViews"
import "FungibleTokenMetadataViews"
import "ViewResolvers"
import "FTViewUtils"

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
    /// Event emitted when a Editable FTView is created
    access(all) event FungibleTokenReviewerEditableFTViewCreated(
        _ address: Address,
        _ contractName: String,
        id: UInt64,
        reviewer: Address
    )
    /// Event emitted when a new Fungible Token is reviewed
    access(all) event FungibleTokenViewResolverUpdated(
        _ address: Address,
        _ contractName: String,
        _ newResolverIdentifier: String
    )
    /// Event emitted when a Fungible Token is evaluated
    access(all) event FungibleTokenReviewEvaluated(
        _ address: Address,
        _ contractName: String,
        _ rank: UInt8,
        _ by: Address
    )
    /// Event emitted when a Fungible Token is commented
    access(all) event FungibleTokenCommented(
        _ address: Address,
        _ contractName: String,
        _ comment: String,
        _ by: Address
    )

    /* --- Variable, Enums and Structs --- */

    access(all) let registryStoragePath: StoragePath
    access(all) let registryPublicPath: PublicPath
    access(all) let reviewerStoragePath: StoragePath
    access(all) let reviewerPublicPath: PublicPath
    access(all) let maintainerStoragePath: StoragePath

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
        fun updateViewResolver(_ viewResolver: @{MetadataViews.Resolver})
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
            if viewResolver == nil && ViewResolvers.borrowContractViewResolver(ftAddress, ftContractName) != nil {
                // If viewResolver is not provided, then create one using the ViewResolvers
                self.viewResolver <- ViewResolvers.createContractViewResolver(address: ftAddress, contractName: ftContractName)
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

        /// Update the view resolver
        ///
        access(contract)
        fun updateViewResolver(_ viewResolver: @{MetadataViews.Resolver}) {
            let old <- self.viewResolver <- viewResolver
            destroy old

            // emit the event
            emit FungibleTokenViewResolverUpdated(
                self.identity.address,
                self.identity.contractName,
                self.viewResolver.getType().identifier
            )
        }

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
        let comments: [ReviewComment]
        access(all)
        var evalRank: Evaluation

        init(
            _ rank: Evaluation,
        ) {
            self.evalRank = rank
            self.comments = []
        }

        /// Update the evaluation rank
        ///
        access(all)
        fun updateEvaluationRank(
            _ rank: Evaluation
        ) {
            self.evalRank = rank
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
        access(all) view
        fun getManagedFTTypes(): [Type]
        access(all) view
        fun getReviewedFTTypes(): [Type]
        access(all) view
        fun getFeaturedFTTypes(): [Type]
        access(all) view
        fun getVerifiedFTTypes(): [Type]
        access(all) view
        fun borrowFTViewReader(_ tokenType: Type): &FTViewUtils.EditableFTView{FTViewUtils.EditableFTViewDataInterface}?
    }

    /// Maintainer interface for the Fungible Token Reviewer
    ///
    access(all) resource interface FungibleTokenReviewMaintainer {
        /// Review the Fungible Token with Evaluation
        access(all)
        fun reviewFTEvalute(_ type: Type, rank: Evaluation)
        /// Review the Fungible Token with Comment
        access(all)
        fun reviewFTComment(_ type: Type, comment: String)
        /// Register a new Fungible Token with the Editable FTView
        access(all)
        fun registerFungibleTokenWithEditableFTView(
            _ ftAddress: Address,
            _ ftContractName: String,
            at: StoragePath
        )
        /// Borrow the FTView editor
        access(all)
        fun borrowFTViewEditor(_ tokenType: Type): &FTViewUtils.EditableFTView{FTViewUtils.EditableFTViewDataInterface, FTViewUtils.FTViewDataEditor}?
    }

    /// The resource for the FT Reviewer
    ///
    access(all) resource FungibleTokenReviewer: FungibleTokenReviewMaintainer, FungibleTokenReviewerInterface, MetadataViews.ResolverCollection {
        access(self)
        let writableRegistryCap: Capability<&Registry{TokenListViewer, TokenListRegister}>
        access(self)
        let storedIdMapping: {UInt64: Type}
        access(self)
        let storedDatas: @{Type: FTViewUtils.EditableFTView}
        access(self)
        let reviewed: {Type: Evaluation}

        init(
            _ cap: Capability<&Registry{TokenListViewer, TokenListRegister}>
        ) {
            pre {
                cap.check(): "Invalid capability"
            }
            self.writableRegistryCap = cap
            self.storedIdMapping = {}
            self.storedDatas <- {}
            self.reviewed = {}
        }

        /// @deprecated in Cadence 1.0
        destroy() {
            destroy self.storedDatas
        }

        // --- Implement the FungibleTokenReviewMaintainer ---

        /// Review the Fungible Token with Evaluation
        ///
        access(all)
        fun reviewFTEvalute(_ type: Type, rank: Evaluation) {
            let registery = self._borrowRegistry()
            let entryRef = registery.borrowFungibleTokenEntry(type)
                ?? panic("Failed to load the Fungible Token Entry")

            if let reviewRef = entryRef.borrowReviewRef(self.uuid) {
                reviewRef.updateEvaluationRank(rank)
            } else {
                entryRef.addRewiew(self.uuid, FTReview(rank))
            }
            // update reviewed status locally
            self.reviewed[type] = rank

            let identity = entryRef.getIdentity()

            // emit the event
            emit FungibleTokenReviewEvaluated(
                identity.address,
                identity.contractName,
                rank.rawValue,
                self.owner?.address ?? panic("Owner not found")
            )
        }

        /// Review the Fungible Token with Comment
        ///
        access(all)
        fun reviewFTComment(_ type: Type, comment: String) {
            let registery = self._borrowRegistry()
            let entryRef = registery.borrowFungibleTokenEntry(type)
                ?? panic("Failed to load the Fungible Token Entry")

            let reviewerAddr = self.owner?.address ?? panic("Owner not found")
            if let reviewRef = entryRef.borrowReviewRef(self.uuid) {
                reviewRef.addComment(comment, reviewerAddr)
            } else {
                entryRef.addRewiew(self.uuid, FTReview(Evaluation.UNVERIFIED))
                entryRef.borrowReviewRef(self.uuid)!.addComment(comment, reviewerAddr)
            }

            let identity = entryRef.getIdentity()
            // emit the event
            emit FungibleTokenCommented(
                identity.address,
                identity.contractName,
                comment,
                reviewerAddr
            )
        }

        /// Register a new Fungible Token with the Editable FTView
        ///
        access(all)
        fun registerFungibleTokenWithEditableFTView(
            _ ftAddress: Address,
            _ ftContractName: String,
            at: StoragePath
        ) {
            let tokenType = FTViewUtils.buildFTVaultType(ftAddress, ftContractName)
                ?? panic("Could not build the FT Type")
            let registery = self._borrowRegistry()
            assert(
                registery.borrowFungibleTokenEntry(tokenType) == nil,
                message: "Fungible Token already registered"
            )
            assert(
                self.storedDatas[tokenType] == nil,
                message: "Editable FTView already exists"
            )

            // create a Editable FTView resource it the reviewer storage
            let editableFTView <- FTViewUtils.createEditableFTView(ftAddress, ftContractName, at)
            let ftViewId = editableFTView.uuid
            // save in the resource
            self.storedDatas[tokenType] <-! editableFTView
            self.storedIdMapping[ftViewId] = tokenType

            let reviewer = self.owner?.address ?? panic("Owner not found")
            // emit the event for editable FTView
            emit FungibleTokenReviewerEditableFTViewCreated(
                ftAddress,
                ftContractName,
                id: ftViewId,
                reviewer: reviewer
            )

            // create the view resolver
            let ftViewResolver <- ViewResolvers.createCollectionViewResolver(
                TokenList.getReviewerCapability(reviewer),
                id: ftViewId
            )
            let ftEntry <- create FungibleTokenEntry(ftAddress, ftContractName, <- ftViewResolver)
            registery.registerFungibleToken(<- ftEntry)
        }

        /// Borrow the FTView editor
        ///
        access(all)
        fun borrowFTViewEditor(_ tokenType: Type): &FTViewUtils.EditableFTView{FTViewUtils.EditableFTViewDataInterface, FTViewUtils.FTViewDataEditor}? {
            return self._borrowEditableFTView(tokenType)
        }

        // --- Implement the FungibleTokenReviewerInterface ---

        /// Return all Fungible Token Types managed by the reviewer
        ///
        access(all) view
        fun getManagedFTTypes(): [Type] {
            return self.storedDatas.keys
        }

        /// Return all Fungible Token Types reviewed by the reviewer
        ///
        access(all) view
        fun getReviewedFTTypes(): [Type] {
            return self.reviewed.keys
        }

        /// Return all Fungible Token Types with FEATURED evaluation
        ///
        access(all) view
        fun getFeaturedFTTypes(): [Type] {
            let reviewedRef = &self.reviewed as &{Type: Evaluation}
            return self.reviewed.keys.filter(fun(type: Type): Bool {
                return reviewedRef[type] == Evaluation.FEATURED
            })
        }

        /// Return all Fungible Token Types with VERIFIED or FEATURED evaluation
        ///
        access(all) view
        fun getVerifiedFTTypes(): [Type] {
            let reviewedRef = &self.reviewed as &{Type: Evaluation}
            return self.reviewed.keys.filter(fun(type: Type): Bool {
                return reviewedRef[type] == Evaluation.VERIFIED || reviewedRef[type] == Evaluation.FEATURED
            })
        }

        /// Borrow the reference of Editable FT View
        ///
        access(all) view
        fun borrowFTViewReader(_ tokenType: Type): &FTViewUtils.EditableFTView{FTViewUtils.EditableFTViewDataInterface}? {
            return self._borrowEditableFTView(tokenType)
        }

        // --- Implement the MetadataViews.ResolverCollection ---

        /// Get the IDs of the view resolvers
        ///
        access(all) view
        fun getIDs(): [UInt64] {
            return self.storedIdMapping.keys
        }

        /// Borrow the view resolver
        /// TODO: Update after Standard V2 is released
        ///
        access(all) view
        fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            var ret: &{MetadataViews.Resolver}? = nil
            if let tokenType = self.storedIdMapping[id] {
                ret = self._borrowEditableFTView(tokenType)
            }
            return ret ?? panic("Failed to borrow the view resolver")
        }

        // --- Internal Methods ---

        /// Borrow the Editable FT View
        ///
        access(self)
        fun _borrowEditableFTView(_ tokenType: Type): &FTViewUtils.EditableFTView? {
            return &self.storedDatas[tokenType] as &FTViewUtils.EditableFTView?
        }

        /// Borrow the Registry
        ///
        access(self)
        fun _borrowRegistry(): &Registry{TokenListViewer, TokenListRegister} {
            return self.writableRegistryCap.borrow()
                ?? panic("This reviewer cannot access writable Registry reference.")
        }
    }

    /// The Maintainer for the Fungible Token Reviewer
    ///
    access(all) resource ReviewMaintainer: FungibleTokenReviewMaintainer {
        access(self)
        let reviewerCap: Capability<&FungibleTokenReviewer{FungibleTokenReviewMaintainer, FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>

        init(
            _ cap: Capability<&FungibleTokenReviewer{FungibleTokenReviewMaintainer, FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>
        ) {
            pre {
                cap.check(): "Invalid capability"
            }
            self.reviewerCap = cap
        }

        /// Review the Fungible Token with Evaluation
        ///
        access(all)
        fun reviewFTEvalute(_ type: Type, rank: Evaluation) {
            self.borrowReviewer().reviewFTEvalute(type, rank: rank)
        }

        /// Review the Fungible Token with Comment
        ///
        access(all)
        fun reviewFTComment(_ type: Type, comment: String) {
            self.borrowReviewer().reviewFTComment(type, comment: comment)
        }

        /// Register a new Fungible Token with the Editable FTView
        ///
        access(all)
        fun registerFungibleTokenWithEditableFTView(
            _ ftAddress: Address,
            _ ftContractName: String,
            at: StoragePath
        ) {
            self.borrowReviewer().registerFungibleTokenWithEditableFTView(ftAddress, ftContractName, at: at)
        }

        /// Borrow the FTView editor
        ///
        access(all)
        fun borrowFTViewEditor(_ tokenType: Type): &FTViewUtils.EditableFTView{FTViewUtils.EditableFTViewDataInterface, FTViewUtils.FTViewDataEditor}? {
            return self.borrowReviewer().borrowFTViewEditor(tokenType)
        }

        /* ---- Internal Methods ---- */

        access(self)
        fun borrowReviewer(): &FungibleTokenReviewer{FungibleTokenReviewMaintainer, FungibleTokenReviewerInterface, MetadataViews.ResolverCollection} {
            return self.reviewerCap.borrow()
                ?? panic("Failed to borrow the reviewer")
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
        access(all) view
        fun borrowFungibleTokenEntry(_ tokenType: Type): &FungibleTokenEntry{FTEntryInterface}?
        // --- Write Methods ---
        /// Register a new standard Fungible Token Entry to the registry
        access(contract)
        fun registerStandardFungibleToken(_ ftAddress: Address, _ ftContractName: String)
    }

    /// Interface for the Token List Register
    ///
    access(all) resource interface TokenListRegister {
        /// Add a new Fungible Token Entry to the registry
        access(contract)
        fun registerFungibleToken(_ ftEntry: @FungibleTokenEntry)
    }

    /// The Token List Registry
    ///
    access(all) resource Registry: TokenListViewer, TokenListRegister {
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
        access(all) view
        fun borrowFungibleTokenEntry(_ tokenType: Type): &FungibleTokenEntry{FTEntryInterface}? {
            return self.borrowFungibleTokenEntryWritableRef(tokenType)
        }

        // ----- Methods for Reviewer  -----

        /// Generate the reviewer capability ID
        access(all) view
        fun generateReviewerCapabilityId(_ addr: Address): String {
            return TokenList.getPathPrefix().concat("PrivateIdentity_".concat(addr.toString()))
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
        ///
        access(contract)
        fun registerFungibleToken(_ ftEntry: @FungibleTokenEntry) {
            pre {
                self.entries[ftEntry.getTokenType()] == nil:
                    "FungibleToken Entry already exists in the registry"
                self.entriesIdMapping[ftEntry.uuid] == nil:
                    "FungibleToken Entry ID already exists in the registry"
            }
            let tokenType = ftEntry.getTokenType()
            self.entries[tokenType] <-! ftEntry

            let ref = self.borrowFungibleTokenEntryWritableRef(tokenType)
                ?? panic("Could not borrow the FT Entry")
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

        // ----- Internal Methods -----

        access(self)
        fun borrowFungibleTokenEntryWritableRef(_ tokenType: Type): &FungibleTokenEntry? {
            return &self.entries[tokenType] as &FungibleTokenEntry?
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
    fun createFungibleTokenReviewer(
        _ cap: Capability<&Registry{TokenListViewer, TokenListRegister}>
    ): @FungibleTokenReviewer {
        return <- create FungibleTokenReviewer(cap)
    }

    /// Create a new Fungible Token Review Maintainer
    ///
    access(all)
    fun createFungibleTokenReviewMaintainer(
        _ cap: Capability<&FungibleTokenReviewer{FungibleTokenReviewMaintainer, FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>
    ): @ReviewMaintainer {
        return <- create ReviewMaintainer(cap)
    }

    /// Get the Fungible Token Reviewer capability
    ///
    access(all)
    fun getReviewerCapability(_ addr: Address): Capability<&FungibleTokenReviewer{FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}> {
        return getAccount(addr)
            .getCapability<&FungibleTokenReviewer{FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
                self.reviewerPublicPath
            )
    }

    /// Borrow the public capability of the Fungible Token Reviewer
    ///
    access(all)
    fun borrowReviewerPublic(_ addr: Address): &FungibleTokenReviewer{FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}? {
        return self.getReviewerCapability(addr).borrow()
    }

    /// Borrow the public capability of  Token List Registry
    ///
    access(all)
    fun borrowRegistry(): &Registry{TokenListViewer} {
        return getAccount(self.account.address)
            .getCapability<&Registry{TokenListViewer}>(self.registryPublicPath)
            .borrow()
            ?? panic("Could not borrow the Registry reference")
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

    /// The prefix for the paths
    ///
    access(all) view
    fun getPathPrefix(): String {
        return "TokenList_".concat(self.account.address.toString()).concat("_")
    }

    init() {
        // Identifiers
        let identifier = TokenList.getPathPrefix()
        self.registryStoragePath = StoragePath(identifier: identifier.concat("_Registry"))!
        self.registryPublicPath = PublicPath(identifier: identifier.concat("_Registry"))!

        self.reviewerStoragePath = StoragePath(identifier: identifier.concat("_Reviewer"))!
        self.reviewerPublicPath = PublicPath(identifier: identifier.concat("_Reviewer"))!

        self.maintainerStoragePath = StoragePath(identifier: identifier.concat("_Maintainer"))!

        // Create the Token List Registry
        let registry <- create Registry()
        self.account.save(<- registry, to: self.registryStoragePath)
        // link the public capability
        // @deprecated in Cadence 1.0
        self.account.link<&Registry{TokenListViewer}>(self.registryPublicPath, target: self.registryStoragePath)

        // Emit the initialized event
        emit ContractInitialized()
    }
}
