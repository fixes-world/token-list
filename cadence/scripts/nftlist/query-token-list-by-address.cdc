import "TokenListHelper"

access(all)
fun main(
    address: Address,
    reviewer: Address?,
): TokenListHelper.QueryResult {
    return TokenListHelper.queryNFTsByAddress(address: address, reviewer: reviewer)
}
