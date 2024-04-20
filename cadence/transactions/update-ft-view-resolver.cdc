import "TokenList"

transaction(
    ftAddress: Address,
    ftContractName: String,
) {
    prepare(acct: AuthAccount) {
        TokenList.updateFungibleTokenViewResolver(ftAddress, ftContractName)
    }
}
