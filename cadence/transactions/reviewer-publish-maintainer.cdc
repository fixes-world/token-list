import "MetadataViews"
import "TokenList"

transaction(
    target: Address
) {
    prepare(acct: AuthAccount) {
        /// ---------- Reviewer Initialization: Start ----------
        if !acct.check<&TokenList.FungibleTokenReviewer>(from: TokenList.reviewerStoragePath) {
            log("Creating a new reviewer")
            let reviewer <- TokenList.createFungibleTokenReviewer()
            acct.save(<- reviewer, to: TokenList.reviewerStoragePath)

            // public the public capability
            acct.link<&TokenList.FungibleTokenReviewer{TokenList.FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
                TokenList.reviewerPublicPath,
                target: TokenList.reviewerStoragePath
            )
        } else {
            log("Reviewer already exists")
        }
        /// ---------- Reviewer Initialization: End ----------

        assert(
            acct.borrow<&TokenList.FungibleTokenReviewer>(
                from: TokenList.reviewerStoragePath
            ) != nil,
            message: "Missing the reviewer capability"
        )

        let maintainerId = TokenList.generateReviewMaintainerCapabilityId(target)
        // link the private cap
        let privatePath = PrivatePath(identifier: maintainerId)!
        acct.unlink(privatePath)
        acct.link<&TokenList.FungibleTokenReviewer{TokenList.FungibleTokenReviewMaintainer, TokenList.FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
            privatePath,
            target: TokenList.reviewerStoragePath
        )
        let cap = acct.getCapability<&TokenList.FungibleTokenReviewer{TokenList.FungibleTokenReviewMaintainer, TokenList.FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
            privatePath
        )
        assert(cap.check(), message: "Failed to link the capability")

        acct.inbox.publish(cap, name: maintainerId, recipient: target)
    }
}
