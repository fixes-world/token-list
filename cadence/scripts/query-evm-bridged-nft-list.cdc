import "TokenListHelper"

access(all)
fun main(
    page: Int,
    size: Int,
    reviewer: Address?,
): TokenListHelper.QueryResult {
    return TokenListHelper.queryEVMBridgedNFTs(page: page, size: size, reviewer: reviewer)
}
