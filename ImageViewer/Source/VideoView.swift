//
//  VideoView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 25/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVFoundation

class VideoView: UIView {

    let previewImageView = UIImageView()

    var image: UIImage? { didSet { previewImageView.image = image } }

    var player: AVPlayer? {

        willSet {

            if newValue == nil {

                if let observablePlayer = player {

                    observablePlayer.removeObserver(self, forKeyPath: "status")
                }
            }
        }

        didSet {

            if  let observablePlayer = self.player,
                let item = self.player?.currentItem,
                let videoLayer = self.layer as? AVPlayerLayer {

                videoLayer.player = observablePlayer
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspect

                observablePlayer.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
                observablePlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)

                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidFinishPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
            }
        }
    }

    func playerDidFinishPlaying() {

        if  let player = self.player,
            let _ = self.player?.currentItem {

            player.seekToTime(CMTime(seconds: 0, preferredTimescale: 1))

            UIView.animateWithDuration(0.3) { [weak self] in

                if let weakself = self {

                    weakself.previewImageView.alpha = 1
                }
            }
        }
    }

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(previewImageView)

        previewImageView.contentMode = .ScaleAspectFill
        previewImageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        previewImageView.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if let status = self.player?.status, let currentTime = self.player?.currentTime().seconds {

            if status == .ReadyToPlay && currentTime != 0 {

                UIView.animateWithDuration(0.3) { [weak self] in

                    if let weakself = self {

                        weakself.previewImageView.alpha = 0
                    }
                }
            }
        }
    }
}

