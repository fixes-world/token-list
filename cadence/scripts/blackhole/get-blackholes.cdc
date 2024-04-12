import "BlackHole"

access(all)
fun main(): [Address] {
    return BlackHole.getRegisteredBlackHoles()
}
