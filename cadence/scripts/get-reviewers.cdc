import "TokenList"

access(all)
fun main(): [Address] {
    let registry = TokenList.borrowRegistry()
    return registry.getReviewers()
}
