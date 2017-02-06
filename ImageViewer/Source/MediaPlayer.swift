//
//  MediaPlayer.swift
//  ImageViewer
//
//  Created by Nasser Munshi on 2/6/17.
//  Copyright © 2017 MailOnline. All rights reserved.
//

import Foundation
import AVFoundation

public class MediaPlayer: NSObject {
    
    public struct Notification {
        public static var status: NSNotification.Name {
            return NSNotification.Name(rawValue: "media-player-status-notif")
        }
        public static var rate: NSNotification.Name {
            return NSNotification.Name(rawValue: "media-player-rate-notif")
        }
    }
    
    public let avPlayer: AVPlayer
    
    public init(avPlayer: AVPlayer) {
        self.avPlayer = avPlayer
        super.init()
        
        //observer to avplayer properties
        self.avPlayer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        self.avPlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)

    }
    
    deinit {
        //Remove observers
        self.avPlayer.removeObserver(self, forKeyPath: "status")
        self.avPlayer.removeObserver(self, forKeyPath: "rate")

    }
    
    //-------------------------------
    //MARK: - Observer Methods
    //-------------------------------
    
    func changePlayerStatus() {
        NotificationCenter.default.post(name: Notification.status, object: avPlayer)
    }
    
    func changePlayerRate() {
        NotificationCenter.default.post(name: Notification.rate, object: avPlayer)
    }
    
    //-------------------------------
    //MARK: - KVO
    //-------------------------------
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "rate" {
            changePlayerRate()
        } else if keyPath == "status" {
            changePlayerStatus()
        }
    }

}
