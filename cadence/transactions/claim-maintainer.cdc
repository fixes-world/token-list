import "MetadataViews"
import "TokenList"

transaction(
    reviewer: Address
) {
    prepare(acct: AuthAccount) {
        let registry = TokenList.borrowRegistry()
        let registryAddr = registry.owner?.address ?? panic("Failed to get registry address")

        let maintainerId = TokenList.generateReviewMaintainerCapabilityId(acct.address)
        let reviewerCap = acct.inbox
            .claim<&TokenList.FungibleTokenReviewer{TokenList.FungibleTokenReviewMaintainer, TokenList.FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
                maintainerId,
                provider: reviewer
            ) ?? panic("Failed to claim reviewer capability")
        assert(
            reviewerCap.check() == true,
            message: "Failed to check reviewer capability"
        )

        if acct.check<&TokenList.ReviewMaintainer>(from: TokenList.maintainerStoragePath) {
            panic("Maintainer already exists")
        }

        let maintainer <- TokenList.createFungibleTokenReviewMaintainer(reviewerCap)
        acct.save(<- maintainer, to: TokenList.maintainerStoragePath)
    }
}
