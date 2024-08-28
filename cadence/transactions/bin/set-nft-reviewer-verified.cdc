import "NFTList"

transaction(
    reviewer: Address,
    verified: Bool,
) {
    prepare(acct: auth(Storage) &Account) {
        let registry = acct.storage
            .borrow<auth(NFTList.SuperAdmin) &NFTList.Registry>(from: NFTList.registryStoragePath)
            ?? panic("Missing or mis-typed TokenList")
        registry.updateReviewerVerified(reviewer, verified)
    }
}
