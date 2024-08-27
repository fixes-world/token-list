import "NFTList"

transaction(
    address: Address,
    contractName: String,
) {
    prepare(acct: &Account) {
        NFTList.ensureNFTCollectionRegistered(address, contractName)
    }
}
