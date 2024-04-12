import "BlackHole"

transaction(
    addr: Address
) {
    prepare(acct: AuthAccount) {
        // register the new account as a black hole receiver
        BlackHole.registerAsBlackHole(addr)
    }
}
