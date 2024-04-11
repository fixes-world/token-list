import "TokenList"

access(all)
fun main(): [ReviewerInfo] {
    let registry = TokenList.borrowRegistry()
    let addrs = registry.getVerifiedReviewers()
    let ret: [ReviewerInfo] = []
    for addr in addrs {
        if let reviewerRef = TokenList.borrowReviewerPublic(addr) {
            ret.append(ReviewerInfo(
                address: addr,
                verified: true,
                name: reviewerRef.getName(),
                url: reviewerRef.getUrl(),
                reviewerRef.getManagedTokenAmount(),
                reviewerRef.getReviewedTokenAmount(),
                reviewerRef.getCustomizedTokenAmount(),
            ))
        }
    }
    return ret
}

access(all) struct ReviewerInfo {
    access(all)
    let address: Address
    access(all)
    let verified: Bool
    access(all)
    let name: String?
    access(all)
    let url: String?
    access(all)
    let managedTokenAmt: Int
    access(all)
    let reviewedTokenAmt: Int
    access(all)
    let customziedTokenAmt: Int

    init(
        address: Address,
        verified: Bool,
        name: String?,
        url: String?,
        _ managedTokenAmt: Int,
        _ reviewedTokenAmt: Int,
        _ customziedTokenAmt: Int,
    ) {
        self.address = address
        self.verified = verified
        self.name = name
        self.url = url
        self.managedTokenAmt = managedTokenAmt
        self.reviewedTokenAmt = reviewedTokenAmt
        self.customziedTokenAmt = customziedTokenAmt
    }
}
