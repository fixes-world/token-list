import "TokenList"

transaction(
    reviewer: Address,
    verified: Bool,
) {
    prepare(acct: AuthAccount) {
        let registry = acct.borrow<&TokenList.Registry>(from: TokenList.registryStoragePath)
            ?? panic("Missing or mis-typed TokenList")
        registry.updateReviewerVerified(reviewer, verified)
    }
}
