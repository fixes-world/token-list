import "NFTList"

access(all)
fun main(
    address: Address,
    contractName: String,
): Bool {
    return NFTList.isNFTCollectionRegistered(address, contractName)
}
