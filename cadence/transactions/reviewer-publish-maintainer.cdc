import "MetadataViews"
import "TokenList"

transaction(
    target: Address
) {
    prepare(acct: AuthAccount) {
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
