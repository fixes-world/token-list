import "FungibleToken"
import "BlackHole"

transaction() {
    prepare(acct: AuthAccount) {
        let storagePath = BlackHole.getBlackHoleReceiverStoragePath()
        if acct.borrow<&AnyResource>(from: storagePath) != nil {
            // If the account already has a BlackHole receiver, do nothing
            return
        }

        // create a new BlackHole receiver and save it to the new account's storage
        let blackHole <- BlackHole.createNewBlackHole()
        acct.save(<- blackHole, to: storagePath)

        // Link the public capability to the new account so it can be used
        acct.link<&BlackHole.Receiver{FungibleToken.Receiver, BlackHole.BlackHolePublic}>(
            BlackHole.getBlackHoleReceiverPublicPath(),
            target: storagePath
        )

        // register the new account as a black hole receiver
        BlackHole.registerAsBlackHole(acct.address)
    }
}
