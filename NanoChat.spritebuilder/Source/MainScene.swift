import Foundation

class MainScene: CCNode {
    
    override init()
    {
        transceive("toast")
    }
    
    override func onEnter()
    {
        println("onEnter")
    }
    
    override func onExit()
    {
        println("onExit")
    }

}
