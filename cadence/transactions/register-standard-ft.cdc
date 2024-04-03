import "TokenList"

transaction(
    ftAddress: Address,
    ftContractName: String,
) {
    prepare(acct: AuthAccount) {
        let registry = TokenList.borrowRegistry()
        registry.registerStandardFungibleToken(ftAddress, ftContractName)
    }
}
