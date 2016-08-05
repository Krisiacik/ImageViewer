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

    var player: AVObservablePlayer? {

        willSet {

            if newValue == nil {

                if let observablePlayer = player {

                    observablePlayer.removeObserver(self, forKeyPath: AVObservablePlayer.ObservableKeyPaths.state)
                }
            }
        }

        didSet {

            if  let observablePlayer = player,
                let videoLayer = self.layer as? AVPlayerLayer {

                videoLayer.player = observablePlayer.player
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspect

                observablePlayer.addObserver(self, forKeyPath: AVObservablePlayer.ObservableKeyPaths.state, options: NSKeyValueObservingOptions.New, context: nil)
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

        if keyPath == AVObservablePlayer.ObservableKeyPaths.state {

            if let observablePlayer = self.player {

                switch observablePlayer.state {

                case AVObservablePlayerStateNone:

                    self.previewImageView.hidden = false

                case AVObservablePlayerStateReady:

                    self.previewImageView.hidden = false

                case AVObservablePlayerStatePlaying:

                    self.previewImageView.hidden = true

                case AVObservablePlayerStateError:

                    self.previewImageView.hidden = false

                default:
                    break
                }
            }
        }
    }
}
