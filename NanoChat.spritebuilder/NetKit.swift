//
//  NetKit.swift
//  NanoChat
//
//  Created by Martin Mumford on 3/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation
import MultipeerConnectivity

// Minimum Possible Networking to start advertising
// This version of NetKit automatically broadcasts and advertises with a single service type, and automatically conncets to all and any peers
// This will not be acceptable in more robust, general versions of NetKit

enum BrowsingStatus
{
    case browser_browsing, browser_stopped
}

enum AdvertisingStatus
{
    case advertiser_advertising, advertiser_stopped
}

public protocol NetKitDelegate {
    
    func peerDiscovered(peerIDString:String)
    func peerRequestFrom(peerIDString:String)
    
    func peerConnecting(peerIDString:String)
    func peerConnected(peerIDString:String)
    func peerDisconnected(peerIDString:String)
    
//    func connecting(myPeerID: MCPeerID, toPeer peer: MCPeerID)
//    func connected(myPeerID: MCPeerID, toPeer peer: MCPeerID)
//    func disconnected(myPeerID: MCPeerID, fromPeer peer: MCPeerID)
//    func receivedData(myPeerID: MCPeerID, data: NSData, fromPeer peer: MCPeerID)
//    func finishReceivingResource(myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: NSURL)
}

class NetKit: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate
{
    var advertiser:MCNearbyServiceAdvertiser?
    var browser:MCNearbyServiceBrowser?
    var session:MCSession
    var myPeerID:MCPeerID
    var browsingStatus:BrowsingStatus
    var advertisingStatus:AdvertisingStatus
    
    var peers:[String:MCPeerID]
    
    var delegate:NetKitDelegate?
    
    init(displayName:String)
    {
        self.myPeerID = MCPeerID(displayName:displayName)
        self.session = MCSession(peer:myPeerID)
        
        self.browsingStatus = .browser_stopped
        self.advertisingStatus = .advertiser_stopped
        
        self.peers = [String:MCPeerID]()
        
        super.init()
        
        self.session.delegate = self
    }
    
    func setDelegate(delegate:NetKitDelegate)
    {
        self.delegate = delegate
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Service Control
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////
    // Transceiving Control (Simulatneously Advertise and Browse)
    //////////////////////////////////////////////////
    
    func startTransceiving(#serviceType:String)
    {
        startAdvertising(serviceType)
        startBrowsing(serviceType)
    }
    
    func resumeTransceiving()
    {
        resumeAdvertising()
        resumeBrowsing()
    }
    
    func pauseTransceiving()
    {
        pauseAdvertising()
        pauseBrowsing()
    }
    
    func stopTransceiving()
    {
        stopAdvertising()
        stopBrowsing()
    }
    
    //////////////////////////////////////////////////
    // Advertising Control
    //////////////////////////////////////////////////
    
    func startAdvertising(serviceType:String)
    {
        advertiser = MCNearbyServiceAdvertiser(peer:myPeerID, discoveryInfo:nil, serviceType:serviceType)
        advertiser?.delegate = self;
        
        advertisingStatus = .advertiser_advertising
        advertiser?.startAdvertisingPeer()
    }
    
    func resumeAdvertising()
    {
        advertisingStatus = .advertiser_advertising
        advertiser?.startAdvertisingPeer()
    }
    
    func pauseAdvertising()
    {
        advertisingStatus = .advertiser_stopped
        advertiser?.stopAdvertisingPeer()
    }
    
    func stopAdvertising()
    {
        advertiser?.delegate = nil
        
        advertisingStatus = .advertiser_stopped
        advertiser?.stopAdvertisingPeer()
    }
    
    //////////////////////////////////////////////////
    // Browsing Control
    //////////////////////////////////////////////////
    
    func startBrowsing(serviceType:String)
    {
        browser = MCNearbyServiceBrowser(peer:myPeerID, serviceType:serviceType)
        browser?.delegate = self;
        
        browsingStatus = .browser_browsing
        browser?.startBrowsingForPeers()
    }
    
    func resumeBrowsing()
    {
        browsingStatus = .browser_browsing
        browser?.startBrowsingForPeers()
    }
    
    func pauseBrowsing()
    {
        browsingStatus = .browser_stopped
        browser?.stopBrowsingForPeers()
    }
    
    func stopBrowsing()
    {
        browser?.delegate = nil
        
        browsingStatus = .browser_stopped
        browser?.stopBrowsingForPeers()
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Utility
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func peerIDToString(peerID:MCPeerID) -> String
    {
        return peerID.displayName
    }
    
    func peerIDWithDisplayName(displayName:String) -> MCPeerID?
    {
        return peers[displayName]
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Events
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //////////////////////////////////////////////////
    // MCNearbyServiceAdvertiserDelegate
    //////////////////////////////////////////////////
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        
        println("AdvertiserDelegate:didNotStartAdvertisingPeer error:\(error)")
        
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        
        println("AdvertiserDelegate:didReceiveInvitationFromPeer:\(peerID)")
    }
    
    //////////////////////////////////////////////////
    // MCNearbyServiceBrowserDelegate
    //////////////////////////////////////////////////
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        
        println("BrowserDelegate:didNotStartBrowserPeer error:\(error)")
        
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        
        println("BrowserDelegate:foundPeer peerID:\(peerID)")
        
        browser.invitePeer(peerID, toSession:session, withContext:nil, timeout:30)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        
        println("BrowserDelegate:lostPeer peerID:\(peerID)")
        
    }
    
    //////////////////////////////////////////////////
    // MCNearbyServiceBrowserDelegate
    //////////////////////////////////////////////////
    
    // MCSessionState: {MCSessionStateConnecting, MCSessionStateConnected, MCSessionStateNotConected}
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState)
    {
        println("Session:peer:\(peerID) didChangeState:\(state.rawValue)")
        
        let peerIDString:String = peerIDToString(peerID)
        
        switch state
        {
            case MCSessionState.Connected:
                delegate?.peerConnected(peerIDString)
            case MCSessionState.Connecting:
                delegate?.peerConnecting(peerIDString)
            case MCSessionState.NotConnected:
                delegate?.peerDisconnected(peerIDString)
            default:
                break
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!)
    {
        println("Session:didReceiveData: \(data) fromPeer: \(peerID)")
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!)
    {
        println("Session:didStartReceivingResourceWithName: \(resourceName) fromPeer: \(peerID)")
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!)
    {
        println("Session:didFinishReceivingResourceWithName: \(resourceName) fromPeer: \(peerID)")
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!)
    {
        // Unused
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!)
    {
        // Unused
    }
    
}
