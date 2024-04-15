import "MetadataViews"
import "TokenList"

transaction() {
    prepare(acct: AuthAccount) {
        /// ---------- Reviewer Initialization: Start ----------
        if !acct.check<@TokenList.FungibleTokenReviewer>(from: TokenList.reviewerStoragePath) {
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
    }
}
