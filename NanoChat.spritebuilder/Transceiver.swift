//
//  Transceiver.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum TransceiverMode {
    case Browse, Advertise, Both
}

public class Transceiver: SessionDelegate {

    var transceiverMode = TransceiverMode.Both
    let advertiser: Advertiser
    let browser: Browser

    public init(displayName: String!) {
        
        println("Transceiver:init")
        
        advertiser = Advertiser(displayName: displayName)
        browser = Browser(displayName: displayName)
        advertiser.delegate = self
        browser.delegate = self
    }

    func startTransceiving(#serviceType: String, discoveryInfo: [String: String]? = nil) {
        
        println("Transceiver:startTransceiving")
        
        advertiser.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
        browser.startBrowsing(serviceType)
        transceiverMode = .Both
    }

    func stopTransceiving() {
        
        println("Transceiver:stopTransceiving")
        
        advertiser.delegate = nil
        browser.delegate = nil
        advertiser.stopAdvertising()
        browser.stopBrowsing()
        advertiser.disconnect()
        browser.disconnect()
    }

    func startAdvertising(#serviceType: String, discoveryInfo: [String: String]? = nil) {
        
         println("Transceiver:startAdvertising")
        
        advertiser.startAdvertising(serviceType: serviceType, discoveryInfo: discoveryInfo)
        transceiverMode = .Advertise
    }

    func startBrowsing(#serviceType: String) {
        
        println("Transceiver:startBrowsing serviceType")
        
        browser.startBrowsing(serviceType)
        transceiverMode = .Browse
    }

    func sessionForPeer(peerID: MCPeerID) -> MCSession? {
        
        println("Transceiver:sessionForPeer:\(peerID)")
        
        if (advertiser.mcSession.connectedPeers as [MCPeerID]).filter({ $0 == peerID }).count > 0 {
            return advertiser.mcSession
        }

        if (browser.mcSession.connectedPeers as [MCPeerID]).filter({ $0 == peerID }).count > 0 {
            return browser.mcSession
        }

        return nil
    }

    public func connecting(myPeerID: MCPeerID, toPeer peer: MCPeerID) {
        
        println("Transceiver:connecting myPeer:\(myPeerID) toPeer:\(peer)")
        
        didConnecting(myPeerID, peer)
    }

    public func connected(myPeerID: MCPeerID, toPeer peer: MCPeerID) {
        
        println("Transceiver:connected myPeer:\(myPeerID) toPeer:\(peer)")
        
        didConnect(myPeerID, peer)
    }

    public func disconnected(myPeerID: MCPeerID, fromPeer peer: MCPeerID) {
        
        println("Transceiver:disconnected myPeer:\(myPeerID) fromPeer:\(peer)")
        
        didDisconnect(myPeerID, peer)
    }

    public func receivedData(myPeerID: MCPeerID, data: NSData, fromPeer peer: MCPeerID) {
        
        println("Transceiver:receivedData myPeer:\(myPeerID) fromPeer:\(peer) data:\(data)")
        
        didReceiveData(data, fromPeer: peer)
    }

    public func finishReceivingResource(myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: NSURL) {
        
        println("Transceiver:finisheReceivingResource myPeer:\(myPeerID) fromPeer:\(peer) resourceName:\(resourceName)")
        
        didFinishReceivingResource(myPeerID, resourceName, fromPeer: peer, atURL: localURL)
    }
}
