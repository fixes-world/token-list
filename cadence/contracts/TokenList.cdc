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
        _ type: Type,
    )
    /// Event emitted when Reviewer Metadata is updated
    access(all) event FungibleTokenReviewerMetadataUpdated(
        _ reviewer: Address,
        name: String?,
        url: String?,
    )
    /// Event emitted when reviewer rank is updated
    access(all) event FungibleTokenReviewerVerifiedUpdated(
        _ reviewer: Address,
        _ isVerified: Bool
    )
    /// Event emitted when reviewer rank is updated
    access(all) event FungibleTokenReviewerRankUpdated(
        _ reviewer: Address,
        _ rank: UInt8
    )
    /// Event emitted when an Editable FTView is created
    access(all) event FungibleTokenReviewerEditableFTViewCreated(
        _ address: Address,
        _ contractName: String,
        id: UInt64,
        reviewer: Address
    )
    /// Evenit emitted when an Editable FTDisplay is created
    access(all) event FungibleTokenReviewerEditableFTDisplayCreated(
        _ address: Address,
        _ contractName: String,
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
        /// Get the FT Type
        access(all) view
        fun getTokenType(): Type
        /// Get the display metadata of the FT
        access(all) view
        fun getDisplay(_ reviewer: Address?): FTViewUtils.FTDisplayWithSource?
        /// Get the vault info the FT
        access(all) view
        fun getVaultData(_ reviewer: Address?): FTViewUtils.FTVaultDataWithSource?
        /// Check if the Fungible Token is reviewed by some one
        access(all) view
        fun isReviewedBy(_ reviewerId: UInt64): Bool
        /// Get the Fungible Token Review
        access(all) view
        fun getFTReview(_ reviewerId: UInt64): FTReview?
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
        var viewResolver: @{MetadataViews.Resolver}?

        init(
            _ ftAddress: Address,
            _ ftContractName: String,
        ) {
            self.reviewers = {}
            self.identity = FTViewUtils.FTIdentity(ftAddress, ftContractName)
            // ensure the contract is a Fungible Token
            let ftContractRef = self.identity.borrowFungibleTokenContract()
            // If viewResolver is not provided, then create one using the ViewResolvers
            if ViewResolvers.borrowContractViewResolver(ftAddress, ftContractName) != nil {
                self.viewResolver <- ViewResolvers.createContractViewResolver(address: ftAddress, contractName: ftContractName)
                // ensure ftView exists
                self.getDisplay(nil)
                self.getVaultData(nil)
            } else {
                // Upgrade in Cadence 1.0 to use the FungibleToken(v2) contract
                // let emptyVault <- ftContractRef.createEmptyVault()
                // if emptyVault.isInstance(Type<@{MetadataViews.Resolver}>()) {
                //     self.viewResolver <- emptyVault as @{MetadataViews.Resolver}
                // } else {
                //     self.viewResolver <- nil
                //     destroy emptyVault
                // }
                self.viewResolver <- nil
            }
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

        /// Get the Fungible Token Review
        ///
        access(all) view
        fun getFTReview(_ reviewerId: UInt64): FTReview? {
            return self.reviewers[reviewerId]
        }

        /// Get the display metadata of the FT
        ///
        access(all) view
        fun getDisplay(_ reviewer: Address?): FTViewUtils.FTDisplayWithSource? {
            var source: Address? = nil
            var retFTDisplay: FungibleTokenMetadataViews.FTDisplay? = nil
            if let viewResolver = self.borrowViewResolver() {
                retFTDisplay = FungibleTokenMetadataViews.getFTDisplay(viewResolver)
            }
            let tokenType = self.getTokenType()
            var reviewerAddr = reviewer
            if reviewerAddr == nil {
                let registry = TokenList.borrowRegistry()
                reviewerAddr = registry.getHighestRankCustomizedReviewer(tokenType)
            }
            if let addr = reviewerAddr {
                log("Reviewer: ".concat(addr.toString()))
                if let reviewerRef = TokenList.borrowReviewerPublic(addr) {
                    if let ftDisplayRef = reviewerRef.borrowFTDisplayReader(self.getTokenType()) {
                        let socials = retFTDisplay?.socials ?? {}
                        let extraSocials = ftDisplayRef.getSocials()
                        for key in extraSocials.keys {
                            socials[key] = extraSocials[key]
                        }
                        source = addr
                        retFTDisplay = FungibleTokenMetadataViews.FTDisplay(
                            name: ftDisplayRef.getName() ?? retFTDisplay?.name ?? "Unkonwn",
                            symbol: ftDisplayRef.getSymbol(),
                            description: ftDisplayRef.getDescription() ?? retFTDisplay?.description ?? "No Description",
                            externalURL: ftDisplayRef.getExternalURL() ?? retFTDisplay?.externalURL ?? MetadataViews.ExternalURL("https://fixes.world"),
                            logos: ftDisplayRef.getLogos(),
                            socials: socials
                        )
                    }
                }
            }
            return retFTDisplay != nil
                ? FTViewUtils.FTDisplayWithSource(source, retFTDisplay!)
                : nil
        }

        /// Get the vault data of the FT
        ///
        access(all) view
        fun getVaultData(_ reviewer: Address?): FTViewUtils.FTVaultDataWithSource? {
            var source: Address? = nil
            var retVaultData: FungibleTokenMetadataViews.FTVaultData? = nil
            // First try to get the data from the view resolver
            if let viewResolver = self.borrowViewResolver() {
                retVaultData = FungibleTokenMetadataViews.getFTVaultData(viewResolver)
            }
            if retVaultData != nil {
                return FTViewUtils.FTVaultDataWithSource(nil, retVaultData!)
            }
            // If not found, then try to get the data from the reviewer
            let tokenType = self.getTokenType()
            var reviewerAddr = reviewer
            if reviewerAddr == nil {
                let registry = TokenList.borrowRegistry()
                reviewerAddr = registry.getHighestRankCustomizedReviewer(tokenType)
            }
            if let addr = reviewerAddr {
                if let reviewerRef = TokenList.borrowReviewerPublic(addr) {
                    let ref = reviewerRef.borrowFTViewReader(tokenType)
                    source = addr
                    retVaultData = ref?.getFTVaultData()
                }
            }
            return retVaultData != nil
                ? FTViewUtils.FTVaultDataWithSource(source, retVaultData!)
                : nil
        }

        /// Get the FT Type
        access(all) view
        fun getTokenType(): Type {
            return self.identity.buildType()
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
        fun updateViewResolver() {
            if ViewResolvers.borrowContractViewResolver(
                self.identity.address,
                self.identity.contractName,
            ) == nil {
                return // no view resolver found
            }
            let newViewResolver <- ViewResolvers.createContractViewResolver(
                address: self.identity.address,
                contractName: self.identity.contractName
            )
            // ensure ftView exists
            self.getDisplay(nil)
            self.getVaultData(nil)

            let old <- self.viewResolver <- newViewResolver
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
        fun borrowViewResolver(): &{MetadataViews.Resolver}? {
            return &self.viewResolver as &{MetadataViews.Resolver}?
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
        fun getAddress(): Address {
            return self.owner?.address ?? panic("Owner not found")
        }
        access(all) view
        fun getName(): String? {
            let metadata = self.getMetadata()
            return metadata["name"]
        }
        access(all) view
        fun getUrl(): String? {
            let metadata = self.getMetadata()
            return metadata["url"]
        }
        access(all) view
        fun getMetadata(): {String: String}
        access(all) view
        fun getManagedTokenAmount(): Int
        access(all) view
        fun getReviewedTokenAmount(): Int
        access(all) view
        fun getCustomizedTokenAmount(): Int
        access(all) view
        fun getManagedFTTypes(): [Type]
        access(all) view
        fun getReviewedFTTypes(): [Type]
        access(all) view
        fun getFeaturedFTTypes(): [Type]
        access(all) view
        fun getVerifiedFTTypes(): [Type]
        access(all) view
        fun borrowFTViewReader(_ tokenType: Type): &AnyResource{FTViewUtils.EditableFTViewDataInterface, FTViewUtils.EditableFTViewDisplayInterface}?
        access(all) view
        fun borrowFTDisplayReader(_ tokenType: Type): &AnyResource{FTViewUtils.EditableFTViewDisplayInterface}?
    }

    /// Maintainer interface for the Fungible Token Reviewer
    ///
    access(all) resource interface FungibleTokenReviewMaintainer {
        /// Update Reviewer Metadata
        access(all)
        fun updateMetadata(name: String?, url: String?)
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
        /// Register the Fungible Token Display Patch
        access(all)
        fun registerFungibleTokenDisplayPatch(
            _ ftAddress: Address,
            _ ftContractName: String
        )
        /// Borrow the FTView editor
        access(all)
        fun borrowFTViewEditor(_ tokenType: Type): &AnyResource{FTViewUtils.EditableFTViewDataInterface, FTViewUtils.FTViewDataEditor, FTViewUtils.FTViewDisplayEditor, FTViewUtils.EditableFTViewDisplayInterface}?
        /// Borrow or create the FTDisplay editor
        access(all)
        fun borrowFTDisplayEditor(_ tokenType: Type): &AnyResource{FTViewUtils.FTViewDisplayEditor, FTViewUtils.EditableFTViewDisplayInterface}?
    }

    /// The resource for the FT Reviewer
    ///
    access(all) resource FungibleTokenReviewer: FungibleTokenReviewMaintainer, FungibleTokenReviewerInterface, MetadataViews.ResolverCollection {
        access(self)
        let metadata: {String: String}
        access(self)
        let storedIdMapping: {UInt64: Type}
        access(self)
        let storedDatas: @{Type: FTViewUtils.EditableFTView}
        access(self)
        let storedDisplayPatches: @{Type: FTViewUtils.EditableFTDisplay}
        access(self)
        let reviewed: {Type: Evaluation}

        init() {
            self.metadata = {}
            self.storedIdMapping = {}
            self.storedDatas <- {}
            self.storedDisplayPatches <- {}
            self.reviewed = {}
        }

        /// @deprecated in Cadence 1.0
        destroy() {
            destroy self.storedDatas
            destroy self.storedDisplayPatches
        }

        // --- Implement the FungibleTokenReviewMaintainer ---

        /// Update Reviewer Metadata
        ///
        access(all)
        fun updateMetadata(name: String?, url: String?) {
            if name != nil {
                self.metadata["name"] = name!
            }

            if url != nil {
                self.metadata["url"] = url!
            }

            // emit the event
            emit FungibleTokenReviewerMetadataUpdated(
                self.getAddress(),
                name: name,
                url: url,
            )
        }

        /// Review the Fungible Token with Evaluation
        ///
        access(all)
        fun reviewFTEvalute(_ type: Type, rank: Evaluation) {
            let registery = TokenList.borrowRegistry()
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
            let registery = TokenList.borrowRegistry()
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
            let registery = TokenList.borrowRegistry()
            let tokenType = FTViewUtils.buildFTVaultType(ftAddress, ftContractName)
                ?? panic("Could not build the FT Type")
            // register the Fungible Token if not exists
            if registery.borrowFungibleTokenEntry(tokenType) == nil {
                registery.registerStandardFungibleToken(ftAddress, ftContractName)
            }

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

            registery.onReviewerFTDataCustomized(self.getAddress(), tokenType)

            // emit the event for editable FTView
            emit FungibleTokenReviewerEditableFTViewCreated(
                ftAddress,
                ftContractName,
                id: ftViewId,
                reviewer: self.getAddress()
            )
        }

        /// Borrow the FTView editor
        ///
        access(all)
        fun borrowFTViewEditor(
            _ tokenType: Type
        ): &AnyResource{FTViewUtils.EditableFTViewDataInterface, FTViewUtils.FTViewDataEditor, FTViewUtils.FTViewDisplayEditor, FTViewUtils.EditableFTViewDisplayInterface}? {
            return self._borrowEditableFTView(tokenType)
        }

        /// Register the Fungible Token Display Patch
        ///
        access(all)
        fun registerFungibleTokenDisplayPatch(
            _ ftAddress: Address,
            _ ftContractName: String
        ) {
            let registery = TokenList.borrowRegistry()

            let tokenType = FTViewUtils.buildFTVaultType(ftAddress, ftContractName)
                ?? panic("Could not build the FT Type")
            assert(
                registery.borrowFungibleTokenEntry(tokenType) != nil,
                message: "Fungible Token not registered"
            )
            assert(
                self.storedDisplayPatches[tokenType] == nil,
                message: "Editable FTDisplay already exists"
            )

            // create a Editable FTDisplay resource it the reviewer storage
            let editableFTDisplay <- FTViewUtils.createEditableFTDisplay(ftAddress, ftContractName)
            let ftDisplayId = editableFTDisplay.uuid
            // save in the resource
            self.storedDisplayPatches[tokenType] <-! editableFTDisplay

            registery.onReviewerFTDataCustomized(self.getAddress(), tokenType)

            // emit the event for editable FTDisplay
            emit FungibleTokenReviewerEditableFTDisplayCreated(
                ftAddress,
                ftContractName,
                reviewer: self.getAddress()
            )
        }

        /// Borrow or create the FTDisplay editor
        ///
        access(all)
        fun borrowFTDisplayEditor(
            _ tokenType: Type
        ): &AnyResource{FTViewUtils.FTViewDisplayEditor, FTViewUtils.EditableFTViewDisplayInterface}? {
            let registery = TokenList.borrowRegistry()
            if let ref = self._borrowEditableFTDisplay(tokenType) {
                return ref
            }
            return self._borrowEditableFTView(tokenType)
        }

        // --- Implement the FungibleTokenReviewerInterface ---

        access(all) view
        fun getMetadata(): {String: String} {
            return self.metadata
        }

        /// Return the amount of Fungible Token which managed by the reviewer
        ///
        access(all) view
        fun getManagedTokenAmount(): Int {
            return self.storedDatas.keys.length
        }

        /// Return the amount of Fungible Token which reviewed by the reviewer
        ///
        access(all) view
        fun getReviewedTokenAmount(): Int {
            return self.reviewed.keys.length
        }

        /// Return the amount of Fungible Token which display customized by the reviewer
        ///
        access(all) view
        fun getCustomizedTokenAmount(): Int {
            return self.storedDatas.keys.length + self.storedDisplayPatches.keys.length
        }

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
        fun borrowFTViewReader(_ tokenType: Type): &FTViewUtils.EditableFTView{FTViewUtils.EditableFTViewDataInterface, FTViewUtils.EditableFTViewDisplayInterface}? {
            return self._borrowEditableFTView(tokenType)
        }

        /// Borrow the FTDisplay editor
        ///
        access(all) view
        fun borrowFTDisplayReader(_ tokenType: Type): &AnyResource{FTViewUtils.EditableFTViewDisplayInterface}? {
            let ref = self._borrowEditableFTDisplay(tokenType)
            if ref != nil {
                return ref
            }
            return self._borrowEditableFTView(tokenType)
        }

        // --- Resource only methods ---

        /// Create a customized view resolver for the Fungible Token
        ///
        access(all)
        fun createCustomizedViewResolver(
            _ ftAddress: Address,
            _ ftContractName: String,
        ): @AnyResource{MetadataViews.Resolver} {
            let tokenType = FTViewUtils.buildFTVaultType(ftAddress, ftContractName)
                ?? panic("Could not build the FT Type")
            let ref = self._borrowEditableFTView(tokenType)
                ?? panic("Editable FTView not found")
            return <- ViewResolvers.createCollectionViewResolver(
                TokenList.getReviewerCapability(self.getAddress()),
                id: ref.uuid
            )
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

        /// Borrow the Editable FT Display
        ///
        access(self)
        fun _borrowEditableFTDisplay(_ tokenType: Type): &FTViewUtils.EditableFTDisplay? {
            return &self.storedDisplayPatches[tokenType] as &FTViewUtils.EditableFTDisplay?
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

        /// Get the reviewer address
        ///
        access(all) view
        fun getReviewerAddress(): Address {
            return self.reviewerCap.address
        }

        /// Update Reviewer Metadata
        ///
        access(all)
        fun updateMetadata(name: String?, url: String?) {
            self._borrowReviewer().updateMetadata(name: name, url: url)
        }

        /// Review the Fungible Token with Evaluation
        ///
        access(all)
        fun reviewFTEvalute(_ type: Type, rank: Evaluation) {
            self._borrowReviewer().reviewFTEvalute(type, rank: rank)
        }

        /// Review the Fungible Token with Comment
        ///
        access(all)
        fun reviewFTComment(_ type: Type, comment: String) {
            self._borrowReviewer().reviewFTComment(type, comment: comment)
        }

        /// Register a new Fungible Token with the Editable FTView
        ///
        access(all)
        fun registerFungibleTokenWithEditableFTView(
            _ ftAddress: Address,
            _ ftContractName: String,
            at: StoragePath
        ) {
            self._borrowReviewer().registerFungibleTokenWithEditableFTView(ftAddress, ftContractName, at: at)
        }

        /// Borrow the FTView editor
        ///
        access(all)
        fun borrowFTViewEditor(_ tokenType: Type): &AnyResource{FTViewUtils.EditableFTViewDataInterface, FTViewUtils.FTViewDataEditor, FTViewUtils.FTViewDisplayEditor, FTViewUtils.EditableFTViewDisplayInterface}? {
            return self._borrowReviewer().borrowFTViewEditor(tokenType)
        }

        /// Register the Fungible Token Display Patch
        ///
        access(all)
        fun registerFungibleTokenDisplayPatch(
            _ ftAddress: Address,
            _ ftContractName: String
        ) {
            self._borrowReviewer().registerFungibleTokenDisplayPatch(ftAddress, ftContractName)
        }

        /// Borrow the FTDisplay editor
        ///
        access(all)
        fun borrowFTDisplayEditor(_ tokenType: Type): &AnyResource{FTViewUtils.FTViewDisplayEditor, FTViewUtils.EditableFTViewDisplayInterface}? {
            return self._borrowReviewer().borrowFTDisplayEditor(tokenType)
        }

        /* ---- Internal Methods ---- */

        access(self)
        fun _borrowReviewer(): &FungibleTokenReviewer{FungibleTokenReviewMaintainer, FungibleTokenReviewerInterface, MetadataViews.ResolverCollection} {
            return self.reviewerCap.borrow()
                ?? panic("Failed to borrow the reviewer")
        }
    }

    /// Interface for the Token List Viewer
    ///
    access(all) resource interface TokenListViewer {
        // --- Read Methods ---
        /// Return all available reviewers
        access(all) view
        fun getReviewers(): [Address]
        /// Get the reviewer rank
        access(all) view
        fun getReviewerRank(_ reviewer: Address): ReviewerRank?
        /// Return all verified reviewers
        access(all) view
        fun getVerifiedReviewers(): [Address]
        /// Return if the reviewer is verified
        access(all) view
        fun isReviewerVerified(_ reviewer: Address): Bool
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
        /// Get the customized reviewers
        access(all) view
        fun getHighestRankCustomizedReviewer(_ tokenType: Type): Address?
        /// Get the Fungible Token Entry by the type
        access(all) view
        fun borrowFungibleTokenEntry(_ tokenType: Type): &FungibleTokenEntry{FTEntryInterface}?
        // --- Write Methods ---
        /// Register a new standard Fungible Token Entry to the registry
        access(contract)
        fun registerStandardFungibleToken(_ ftAddress: Address, _ ftContractName: String)
        /// Invoked when a new Fungible Token is customized by the reviewer
        access(contract)
        fun onReviewerFTDataCustomized(_ reviewer: Address, _ tokenType: Type)
    }

    access(all) enum ReviewerRank: UInt8 {
        access(all) case NORMAL
        access(all) case ADVANCED
        access(all) case EXPERT
    }

    /// The Token List Registry
    ///
    access(all) resource Registry: TokenListViewer {
        // Address => isVerified
        access(self)
        let verifiedReviewers: {Address: Bool}
        access(self)
        let reviewerRanks: {Address: ReviewerRank}
        // FT Type => FT Entry
        access(self)
        let entries: @{Type: FungibleTokenEntry}
        // FT Entry ID => FT Type
        access(self)
        let entriesIdMapping: {UInt64: Type}
        // Address => [FTContractName]
        access(self)
        let addressMapping: {Address: [String]}
        // Customized FT Views
        access(self)
        let customizedFTViews: {Type: [Address]}

        init() {
            self.verifiedReviewers = {}
            self.reviewerRanks = {}
            self.entriesIdMapping = {}
            self.entries <- {}
            self.addressMapping = {}
            self.customizedFTViews = {}
        }

        // @deprecated in Cadence 1.0
        destroy() {
            destroy self.entries
        }

        // ----- Read Methods -----

        /// Return all available reviewers
        ///
        access(all) view
        fun getReviewers(): [Address] {
            return self.reviewerRanks.keys
        }

        /// Get the reviewer rank
        ///
        access(all) view
        fun getReviewerRank(_ reviewer: Address): ReviewerRank? {
            return self.reviewerRanks[reviewer]
        }

        /// Return all verified reviewers
        ///
        access(all) view
        fun getVerifiedReviewers(): [Address] {
            return self.verifiedReviewers.keys
        }

        /// Return if the reviewer is verified
        ///
        access(all) view
        fun isReviewerVerified(_ reviewer: Address): Bool {
            return self.verifiedReviewers[reviewer] ?? false
        }

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
            if start > max {
                return []
            }
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

        /// Get the highest rank customized reviewers
        ///
        access(all) view
        fun getHighestRankCustomizedReviewer(_ tokenType: Type): Address? {
            if let reviewers = self.customizedFTViews[tokenType] {
                var highestRank: ReviewerRank? = nil
                var highestReviewer: Address? = nil
                for reviewer in reviewers {
                    if let rank = self.reviewerRanks[reviewer] {
                        if highestRank == nil || rank.rawValue > highestRank!.rawValue || self.verifiedReviewers[reviewer] == true {
                            highestRank = rank
                            highestReviewer = reviewer
                            // break if the reviewer is verified
                            if self.verifiedReviewers[reviewer] == true {
                                break
                            }
                        }
                    }
                }
                return highestReviewer
            }
            return nil
        }

        /// Get the Fungible Token Entry by the type
        access(all) view
        fun borrowFungibleTokenEntry(_ tokenType: Type): &FungibleTokenEntry{FTEntryInterface}? {
            return self.borrowFungibleTokenEntryWritableRef(tokenType)
        }

        // ----- Write Methods -----

        /// Update the reviewer verified status
        ///
        access(all)
        fun updateReviewerVerified(_ reviewer: Address, _ verified: Bool) {
            pre {
                TokenList.borrowReviewerPublic(reviewer) != nil: "FT Reviewer not found"
            }
            self.verifiedReviewers[reviewer] = verified

            // emit the event
            emit FungibleTokenReviewerVerifiedUpdated(
                reviewer,
                verified
            )
        }

        /// Register a new standard Fungible Token Entry to the registry
        ///
        access(contract)
        fun registerStandardFungibleToken(_ ftAddress: Address, _ ftContractName: String) {
            pre {
                TokenList.isFungibleTokenRegistered(ftAddress, ftContractName) == false: "Fungible Token already registered"
            }
            self._registerFungibleToken(<- create FungibleTokenEntry(ftAddress, ftContractName))
        }

        /// Invoked when a new Fungible Token is customized by the reviewer
        ///
        access(contract)
        fun onReviewerFTDataCustomized(_ reviewer: Address, _ tokenType: Type) {
            pre {
                TokenList.borrowReviewerPublic(reviewer) != nil: "FT Reviewer not found"
            }
            // ensure the tokenType exists
            if self.customizedFTViews[tokenType] == nil {
                self.customizedFTViews[tokenType] = []
            }
            // add the reviewer to the list
            if let arrRef = &self.customizedFTViews[tokenType] as &[Address]? {
                if arrRef.firstIndex(of: reviewer) == nil {
                    self.customizedFTViews[tokenType]?.append(reviewer)
                }
            }
            // update the rank
            self._updateReviewerRank(reviewer)
        }

        // ----- Internal Methods -----

        access(self)
        fun _updateReviewerRank(_ reviewer: Address) {
            let reviewerRef = TokenList.borrowReviewerPublic(reviewer)
                ?? panic("Could not find the FT Reviewer")
            let oldRank = self.reviewerRanks[reviewer]
            var newRank: TokenList.ReviewerRank? = nil
            // ensure the reviewer rank exists
            if self.reviewerRanks[reviewer] == nil {
                newRank = ReviewerRank.NORMAL
            } else {
                // update the rank by the amount of customized FT
                let managedAmt = reviewerRef.getManagedTokenAmount()
                let reviewedAmt = reviewerRef.getReviewedTokenAmount()
                let customizedAmt = reviewerRef.getCustomizedTokenAmount()
                let weight = managedAmt * 10 + customizedAmt * 5 + reviewedAmt
                if weight >= 1000 {
                    newRank = ReviewerRank.EXPERT
                } else if weight >= 200 {
                    newRank = ReviewerRank.ADVANCED
                }
            }

            if newRank != nil && oldRank != newRank {
                self.reviewerRanks[reviewer] = newRank!
                // emit the event
                emit FungibleTokenReviewerRankUpdated(
                    reviewer,
                    newRank!.rawValue
                )
            }
        }

        /// Add a new Fungible Token Entry to the registry
        ///
        access(self)
        fun _registerFungibleToken(_ ftEntry: @FungibleTokenEntry) {
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

            // emit the event
            emit FungibleTokenRegistered(
                ref.identity.address,
                ref.identity.contractName,
                tokenType
            )
        }

        access(self)
        fun borrowFungibleTokenEntryWritableRef(_ tokenType: Type): &FungibleTokenEntry? {
            return &self.entries[tokenType] as &FungibleTokenEntry?
        }

        access(self)
        fun borrowAddressContractsRef(_ addr: Address): &[String]? {
            return &self.addressMapping[addr] as &[String]?
        }
    }

    /* --- Public Methods --- */

    /// Create a new Fungible Token Reviewer
    ///
    access(all)
    fun createFungibleTokenReviewer(): @FungibleTokenReviewer {
        return <- create FungibleTokenReviewer()
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
        let registry: &TokenList.Registry{TokenList.TokenListViewer} = self.borrowRegistry()
        if let ftType = FTViewUtils.buildFTVaultType(address, contractName) {
            return registry.borrowFungibleTokenEntry(ftType) != nil
        }
        return false
    }

    /// Try to register a new Fungible Token, if already registered, then do nothing
    ///
    access(all)
    fun ensureFungibleTokenRegistered(_ ftAddress: Address, _ ftContractName: String) {
        if !self.isFungibleTokenRegistered(ftAddress, ftContractName) {
            let registry = self.borrowRegistry()
            registry.registerStandardFungibleToken(ftAddress, ftContractName)
        }
    }

    /// The prefix for the paths
    ///
    access(all) view
    fun getPathPrefix(): String {
        return "TokenList_".concat(self.account.address.toString()).concat("_")
    }

    /// Generate the review maintainer capability ID
    ///
    access(all) view
    fun generateReviewMaintainerCapabilityId(_ addr: Address): String {
        return TokenList.getPathPrefix().concat("PrivateIdentity_ReviewMaintainer_".concat(addr.toString()))
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
