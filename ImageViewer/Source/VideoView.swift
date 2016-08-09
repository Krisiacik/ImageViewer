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

    private let previewImageView = UIImageView()
    var image: UIImage? { didSet { previewImageView.image = image } }
    var player: AVPlayer? {

        willSet {

            if newValue == nil {

                player?.removeObserver(self, forKeyPath: "status")
                player?.removeObserver(self, forKeyPath: "rate")
            }
        }

        didSet {

            if  let player = self.player,
                let videoLayer = self.layer as? AVPlayerLayer {

                videoLayer.player = player
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspect

                player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
                player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
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

    deinit {

        player?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "rate")
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if let status = self.player?.status, let rate = self.player?.rate  {

            if status == .ReadyToPlay && rate != 0 {

                UIView.animateWithDuration(0.3) { [weak self] in

                    if let weakself = self {

                        weakself.previewImageView.alpha = 0
                    }
                }
            }
        }
    }
}

