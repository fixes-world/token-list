import "TokenListHelper"

access(all)
fun main(
    ftAddress: Address,
    reviewer: Address?,
): TokenListHelper.QueryResult {
    return TokenListHelper.queryFTsByAddress(ftAddress: ftAddress, reviewer: reviewer)
}
