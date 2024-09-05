import "BlackHole"

transaction(
    addr: Address
) {
    prepare(acct: &Account) {
        // register the new account as a black hole receiver
        BlackHole.registerAsBlackHole(addr)
    }
}
