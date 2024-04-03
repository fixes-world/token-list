import "TokenList"

transaction(
    target: Address
) {
    prepare(acct: AuthAccount) {
        let reviewerCapId = TokenList.generateReviewerCapabilityId(target)
        // link the private cap
        let privatePath = PrivatePath(identifier: reviewerCapId)!
        acct.unlink(privatePath)
        acct.link<&TokenList.Registry{TokenList.TokenListViewer, TokenList.TokenListRegister}>(
            privatePath,
            target: TokenList.registryStoragePath
        )
        let writableRegistryCap = acct.getCapability<&TokenList.Registry{TokenList.TokenListViewer, TokenList.TokenListRegister}>(
            privatePath
        )
        assert(writableRegistryCap.check(), message: "Failed to link the capability")

        acct.inbox.publish(writableRegistryCap, name: reviewerCapId, recipient: target)
    }
}
