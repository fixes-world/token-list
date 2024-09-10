import "EVMTokenList"

access(all)
fun main(
    evmContractAddress: String,
): Bool {
    return EVMTokenList.isEVMAddressRegistered(evmContractAddress)
}
