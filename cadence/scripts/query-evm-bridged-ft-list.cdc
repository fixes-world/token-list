import "TokenListHelper"

access(all)
fun main(
    page: Int,
    size: Int,
    reviewer: Address?,
): TokenListHelper.QueryResult {
    return TokenListHelper.queryEVMBridgedFTs(page: page, size: size, reviewer: reviewer)
}
