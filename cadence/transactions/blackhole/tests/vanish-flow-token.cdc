import "FlowToken"
import "FungibleToken"
import "BlackHole"

transaction(
    amount: UFix64
) {
    let flowVaultRef: &FlowToken.Vault

    prepare(acct: AuthAccount) {
        self.flowVaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow a reference to the Flow Vault!")
    }

    execute {
        log("Before withdrawal:".concat(self.flowVaultRef.balance.toString()))
        BlackHole.vanish(<- self.flowVaultRef.withdraw(amount: amount))
        log("After withdrawal:".concat(self.flowVaultRef.balance.toString()))
    }
}
