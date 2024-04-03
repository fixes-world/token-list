import "MetadataViews"
import "TokenList"

transaction() {
    prepare(acct: AuthAccount) {
        let registry = TokenList.borrowRegistry()
        let registryAddr = registry.owner?.address ?? panic("Failed to get registry address")

        let reviewerId = TokenList.generateReviewerCapabilityId(acct.address)
        let registryPrivCap = acct.inbox
            .claim<&TokenList.Registry{TokenList.TokenListViewer, TokenList.TokenListRegister}>(
                reviewerId,
                provider: registryAddr
            ) ?? panic("Failed to claim registry capability")
        assert(
            registryPrivCap.check() == true,
            message: "Failed to check registry capability"
        )

        if acct.check<&TokenList.FungibleTokenReviewer>(from: TokenList.reviewerStoragePath) {
            panic("Reviewer already exists")
        }

        let reviewer <- TokenList.createFungibleTokenReviewer(registryPrivCap)
        acct.save(<- reviewer, to: TokenList.reviewerStoragePath)

        // public the public capability
        acct.link<&TokenList.FungibleTokenReviewer{TokenList.FungibleTokenReviewerInterface, MetadataViews.ResolverCollection}>(
            TokenList.reviewerPublicPath,
            target: TokenList.reviewerStoragePath
        )
    }
}
