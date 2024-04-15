
access(all)
fun main(
    addr: Address
): [String] {
    let names = getAccount(addr).contracts.names
    for name in names {
        log(name)
    }
    return names
}
