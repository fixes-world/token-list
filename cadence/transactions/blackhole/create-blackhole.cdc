import "FungibleToken"
import "BlackHole"

transaction() {
    prepare(acct: auth(Storage, Capabilities) &Account) {
        let storagePath = BlackHole.getBlackHoleReceiverStoragePath()
        if acct.storage.borrow<&AnyResource>(from: storagePath) != nil {
            // If the account already has a BlackHole receiver, do nothing
            return
        }

        // create a new BlackHole receiver and save it to the new account's storage
        let blackHole <- BlackHole.createNewBlackHole()
        acct.storage.save(<- blackHole, to: storagePath)

        // Link the public capability to the new account so it can be used
        let cap = acct.capabilities.storage.issue<&BlackHole.Receiver>(storagePath)
        acct.capabilities.publish(cap, at: BlackHole.getBlackHoleReceiverPublicPath())
    }
}
