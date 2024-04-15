import "MetadataViews"
import "TokenList"

transaction(
    name: String?,
    url: String?,
) {
    let maintainer: &{TokenList.FungibleTokenReviewMaintainer}

    prepare(acct: AuthAccount) {
        var maintainer: &{TokenList.FungibleTokenReviewMaintainer}? = nil
        // Try borrow maintainer
        if acct.check<@{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.reviewerStoragePath) {
            maintainer = acct.borrow<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.reviewerStoragePath)
                ?? panic("Failed to load FungibleTokenReviewMaintainer from reviewer")
        }
        // Try borrow review
        if !acct.check<@{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.maintainerStoragePath) {
            log("Creating a new reviewer")
            let reviewer <- TokenList.createFungibleTokenReviewer()
            acct.save(<- reviewer, to: TokenList.reviewerStoragePath)

            // public the public capability
            acct.link<&TokenList.FungibleTokenReviewer{TokenList.FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
                TokenList.reviewerPublicPath,
                target: TokenList.reviewerStoragePath
            )
        }
        maintainer = acct.borrow<&{TokenList.FungibleTokenReviewMaintainer}>(from: TokenList.maintainerStoragePath)
                ?? panic("Failed to load FungibleTokenReviewMaintainer from review maintainer")

        self.maintainer = maintainer ?? panic("Missing maintainer")
    }

    execute {
        self.maintainer.updateMetadata(name: name, url: url)
    }
}
