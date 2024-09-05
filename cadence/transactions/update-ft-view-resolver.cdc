import "TokenList"

transaction(
    ftAddress: Address,
    ftContractName: String,
) {
    prepare(acct: &Account) {
        TokenList.updateFungibleTokenViewResolver(ftAddress, ftContractName)
    }
}
