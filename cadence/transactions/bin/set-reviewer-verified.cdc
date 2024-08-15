import "TokenList"

transaction(
    reviewer: Address,
    verified: Bool,
) {
    prepare(acct: auth(Storage) &Account) {
        let registry = acct.storage.borrow<auth(TokenList.SuperAdmin) &TokenList.Registry>(from: TokenList.registryStoragePath)
            ?? panic("Missing or mis-typed TokenList")
        registry.updateReviewerVerified(reviewer, verified)
    }
}
