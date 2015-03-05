import Foundation

class MainScene: CCNode, NetKitDelegate
{
    var netkit:NetKit
    
    override init()
    {
        // For now, we initialize this as a random display name. Eventually, the user will enter a name.
        let randomNumberString:String = String(Int(arc4random_uniform(100)))
        let displayName:String = "Derp" + randomNumberString
        
        netkit = NetKit(displayName:displayName)
    }
    
    override func onEnter()
    {
        println("onEnter")
        
        netkit.setDelegate(self)
        netkit.startTransceiving(serviceType:"derp")
    }
    
    override func onExit()
    {
        println("onExit")
    }
    
    /////////////////////////
    // NetKit Delegate
    /////////////////////////
    
    func peerDiscovered(peerIDString: String)
    {
        println("PEER DISCOVERED: \(peerIDString)")
    }
    
    func peerRequestFrom(peerIDString: String)
    {
        println("PEER REQUEST FROM: \(peerIDString)")
    }
    
    func peerConnected(peerIDString:String)
    {
        println("PEER CONNECTED: \(peerIDString)")
    }
    
    func peerConnecting(peerIDString:String)
    {
        println("PEER CONNECTING: \(peerIDString)")
    }
    
    func peerDisconnected(peerIDString:String)
    {
        println("PEER DISCONNECTED: \(peerIDString)")
    }
}
