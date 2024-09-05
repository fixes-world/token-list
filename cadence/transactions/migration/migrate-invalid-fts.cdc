import "TokenList"

transaction() {

    prepare(acct: auth(BorrowValue) &Account) {
        let registry = acct.storage.borrow<auth(TokenList.SuperAdmin) &TokenList.Registry>(from: TokenList.registryStoragePath)
            ?? panic("Missing or mis-typed TokenList")

        let tokenTypes = registry.getAllFTEntries()
        for tokenType in tokenTypes {
            if tokenType.isRecovered {
                registry.removeFungibleToken(tokenType)
            }
        }
    }
}
