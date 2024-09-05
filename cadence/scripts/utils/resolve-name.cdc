import "FIND"
import "Domains"

access(all)
fun main(
    address: Address
): String? {
    if let name = FIND.reverseLookup(address) {
        return name.concat(".find")
    } else {
        let account = getAccount(address)
        let exists = account.capabilities.exists(Domains.CollectionPublicPath)
        if exists == false {
            return nil
        }

        var flownsName = ""

        let collectionCap = account.capabilities.get<&{Domains.CollectionPublic}>(Domains.CollectionPublicPath)
        let collection = collectionCap.borrow()!
        let ids = collection.getIDs()

        for id in ids {
            let domain = collection.borrowDomain(id: id)!
            let isDefault = domain.getText(key: "isDefault")
            flownsName = domain.getDomainName()
            if isDefault == "true" {
                break
            }
        }

        return flownsName
    }
}
