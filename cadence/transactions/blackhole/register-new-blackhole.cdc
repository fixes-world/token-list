import "FungibleToken"
import "BlackHole"

transaction() {
    prepare(acct: AuthAccount) {
        let newAcct = AuthAccount(payer: acct)

        // create a new BlackHole receiver and save it to the new account's storage
        let blackHole <- BlackHole.createNewBlackHole()
        let storagePath = BlackHole.getBlackHoleReceiverStoragePath()
        newAcct.save(<- blackHole, to: storagePath)

        // Link the public capability to the new account so it can be used
        newAcct.link<&BlackHole.Receiver{FungibleToken.Receiver, BlackHole.BlackHolePublic}>(
            BlackHole.getBlackHoleReceiverPublicPath(),
            target: storagePath
        )

        // register the new account as a black hole receiver
        BlackHole.registerAsBlackHole(newAcct.address)
    }
}
