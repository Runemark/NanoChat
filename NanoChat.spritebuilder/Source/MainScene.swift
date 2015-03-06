import Foundation

class MainScene: CCNode, NetKitDelegate, UITextFieldDelegate
{
    var netkit:NetKit
    var info:DeviceInfo
    var interfaceUnit:Double
    
    var uiNode:CCNode
    
    // Random Interface Stuff
    var nameField:UITextField
    var textInputHeight:Double
    
    override init()
    {
        info = DeviceInfo()
        
        nameField = UITextField()
        
        interfaceUnit = Double(info.view.height/10)
        if (info.category == .kDevice_iPadRetina)
        {
            interfaceUnit = Double(info.view.height/15)
        }
        
        textInputHeight = 0.7
        
        uiNode = CCNode()
        
        // For now, we initialize this as a random display name. Eventually, the user will enter a name.
        let randomNumberString:String = String(Int(arc4random_uniform(100)))
        let displayName:String = "Derp" + randomNumberString
        
        netkit = NetKit(displayName:displayName)
    }
    
    override func onEnter()
    {
        
        // call this FIRST
        super.onEnter()
        
        // Remove obnoxious SpriteBuilder pregenerated scene content
        self.removeAllChildren()
        
        println("onEnter")
        
        self.addChild(uiNode)
        
        netkit.setDelegate(self)
        netkit.startTransceiving(serviceType:"derp")
    }
    
    override func onEnterTransitionDidFinish() {
        
        // call this FIRST
        super.onEnterTransitionDidFinish()
        println("onEnterTransitionDidFinish")
        
        addCenteredTextInputWithPlaceHolder("Screen Name", yPercent:(1-textInputHeight), textField:nameField)
    }
    
    override func onExitTransitionDidStart()
    {
        
        println("onExitTransitionDidStart")
        // call this LAST
        super.onExit()
    }
    
    override func onExit()
    {
        nameField.removeFromSuperview()
        
        println("onExit")
        // call this LAST
        super.onExit()
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
    
    //////////////////////////////
    // Interface
    //////////////////////////////
    
    func addCenteredTextInputWithPlaceHolder(placeholder:String, yPercent:Double, textField:UITextField)
    {
        let textInputBoxWidth = interfaceUnit*12
        let textInputBoxHeight = interfaceUnit
        let label_box_buffer = interfaceUnit
        let textBracketWidth = textInputBoxHeight*0.625
        let approximateTotalBoxWidth = textInputBoxWidth + label_box_buffer + textBracketWidth
        let approximateSideWidth = Double((Double(info.view.width) - Double(approximateTotalBoxWidth))/2)
        
        println("interfaceUnit:\(interfaceUnit) tIBW:\(textInputBoxWidth) tIBH:\(textInputBoxHeight) l_b_b:\(label_box_buffer) tBW:\(textBracketWidth) appTBW:\(approximateTotalBoxWidth) appSW:\(approximateSideWidth)")
        
        textField.frame = CGRectMake(CGFloat(approximateSideWidth + label_box_buffer), CGFloat(info.view.height*CGFloat(yPercent)), CGFloat(textInputBoxWidth), CGFloat(textInputBoxHeight))
        textField.returnKeyType = UIReturnKeyType.Done
        textField.delegate = self
        textField.textAlignment = NSTextAlignment.Center
        textField.textColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
        textField.font = UIFont(name:"Myriad", size:17.0)
        textField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes:[NSForegroundColorAttributeName:UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.5)])
        
        CCDirector.sharedDirector().view.addSubview(textField)
        
        var inputBoundingBox = boundingBoxForAppleUIRect(textField.frame)
        inputBoundingBox.opacity = 0.0
        uiNode.addChild(inputBoundingBox)
    }
    
    func boundingBoxForAppleUIRect(rect:CGRect) -> CCNode
    {
        var boundingBox:CCNode = CCNode()
        
        let cocosRect:CGRect = cocosRectForAppleUIRect(rect)
        
        let midElementWidth:Double = Double(cocosRect.size.width)
        let boundingBoxHeight:Double = Double(cocosRect.size.height)
        let sideElementWidth:Double = Double(boundingBoxHeight*0.625)
        
        var boundBox_Left:CCSprite = CCSprite(imageNamed:"BoundBox_Side.png")
        boundBox_Left.resizeNode(sideElementWidth, y:boundingBoxHeight)
        boundBox_Left.position = CGPointMake(CGFloat(-1*sideElementWidth/2), CGFloat(-1*boundingBoxHeight/2))
        boundingBox.addChild(boundBox_Left)
        
        var boundBox_Right:CCSprite = CCSprite(imageNamed:"BoundBox_Side.png")
        boundBox_Right.resizeNode(-1*sideElementWidth, y:boundingBoxHeight)
        boundBox_Right.position = CGPointMake(CGFloat(midElementWidth+sideElementWidth/2), CGFloat(-1*boundingBoxHeight/2))
        boundingBox.addChild(boundBox_Right)
        
        var boundBox_Mid:CCSprite = CCSprite(imageNamed:"BoundBox_Mid.png")
        boundBox_Mid.resizeNode(midElementWidth, y:boundingBoxHeight)
        boundBox_Mid.position = CGPointMake(CGFloat(midElementWidth/2), CGFloat(-1*boundingBoxHeight/2))
        boundingBox.addChild(boundBox_Mid)
        
        boundingBox.position = CGPointMake(cocosRect.origin.x, cocosRect.origin.y)
        
        return boundingBox
    }
    
    func cocosRectForAppleUIRect(rect:CGRect) -> CGRect
    {
        return CGRectMake(rect.origin.x, info.view.height - rect.origin.y, rect.size.width, rect.size.height)
    }

}
