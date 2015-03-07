//
//  ChatScene.swift
//  NanoChat
//
//  Created by Martin Mumford on 3/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class ChatScene : CCScene, NetKitDelegate
{
    var netKit:NetKit
    
    init(displayName:String)
    {
        self.netKit = NetKit(displayName:displayName)
    }
    
    override func onEnter()
    {
        // call this FIRST
        super.onEnter()
        
        netKit.setDelegate(self)
        netKit.startTransceiving(serviceType:"derp")
        
        println("onEnter")
    }
    
    override func onEnterTransitionDidFinish() {
        
        // call this FIRST
        super.onEnterTransitionDidFinish()
        println("onEnterTransitionDidFinish")
    }
    
    override func onExitTransitionDidStart()
    {
        
        println("onExitTransitionDidStart")
        // call this LAST
        super.onExit()
    }
    
    override func onExit()
    {
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
}
