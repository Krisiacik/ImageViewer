//
//  AVObservablePlayer.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/08/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import Foundation
import AVFoundation

let AVObservablePlayerStateNone     = "AVObservablePlayerStateNone"
let AVObservablePlayerStateReady    = "AVObservablePlayerStateReady"
let AVObservablePlayerStatePlaying  = "AVObservablePlayerStatePlaying"
let AVObservablePlayerStatePaused   = "AVObservablePlayerStatePaused"
let AVObservablePlayerStateError    = "AVObservablePlayerStateError"



class AVObservablePlayer: NSObject {

    struct ObservableKeyPaths {

        static let state = "state"
        static let duration = "duration"
        static let currentTime = "currentTime"
    }

    dynamic private(set) var state: String = AVObservablePlayerStateNone
    dynamic private(set) var duration: NSTimeInterval = Double.NaN
    dynamic private(set) var currentTime: NSTimeInterval = Double.NaN

    let player: AVPlayer
    private var periodicObserver: AnyObject?

    init(player: AVPlayer) {

        self.player = player

        super.init()

        configureObservers()
    }

    deinit {

        if let periodicObserver = self.periodicObserver {

            self.player.removeTimeObserver(periodicObserver)
        }

        self.removeObserver(self, forKeyPath: "status")
        self.removeObserver(self, forKeyPath: "rate")
    }

    func configureObservers() {

        self.player.addObserver(self, forKeyPath:"status", options: NSKeyValueObservingOptions.New, context:nil)
        self.player.addObserver(self, forKeyPath:"rate", options: NSKeyValueObservingOptions.New, context:nil)

        let time = CMTime(value: 1, timescale: 1)

        periodicObserver = self.player.addPeriodicTimeObserverForInterval(time, queue: nil) { [weak self] time in

            self?.currentTime = Double(CMTimeGetSeconds(time)) as NSTimeInterval
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if keyPath == "rate" || keyPath == "status"  {

            guard self.player.currentItem != nil else {

                self.state = AVObservablePlayerStateNone
                duration = Double.NaN
                currentTime = Double.NaN
                return
            }

            guard self.player.error == nil else {

                self.state = AVObservablePlayerStateError

                return
            }

            switch self.player.status {

            case .ReadyToPlay where self.player.rate == 0 && self.player.currentTime().toSeconds() == 0:

                self.state = AVObservablePlayerStateReady
                duration = self.player.currentItem?.duration.toSeconds() ?? Double.NaN
                currentTime = self.player.currentTime().toSeconds()

            case .ReadyToPlay where self.player.rate == 0 && self.player.currentTime().toSeconds() != 0:

                self.state = AVObservablePlayerStatePaused
                duration = self.player.currentItem?.duration.toSeconds() ?? Double.NaN
                currentTime = self.player.currentTime().toSeconds()

            case .ReadyToPlay where self.player.rate != 0:

                self.state = AVObservablePlayerStatePlaying
                
            default:
                
                self.state = AVObservablePlayerStateNone
            }
        }
    }

    func play() {

        self.player.play()
    }

    func pause() {

        self.player.pause()
    }

    func seekTime(time: NSTimeInterval) {

        if let video = self.player.currentItem {

            let videoDuration = video.duration.toSeconds()
            let normalizedTime = max(0, min(time, videoDuration))

            self.player.seekToTime(CMTimeMakeWithSeconds(normalizedTime, 1000000))
        }
    }
}

extension CMTime {

    func toSeconds() -> NSTimeInterval {

        let x = self.value
        return Double(CMTimeGetSeconds(self)) as NSTimeInterval
    }
}

