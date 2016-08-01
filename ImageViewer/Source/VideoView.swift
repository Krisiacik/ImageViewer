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

        didSet {

            print("RATE \(self.player!.rate)")

            let status = (self.player!.status == .ReadyToPlay)  ? "ReadyToPlay" : "None"
            print("STATUS \(status)")

            if let videoLayer = self.layer as? AVPlayerLayer {

                videoLayer.player = player
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspect

                player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
                player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
                player?.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
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

    override func layoutSubviews() {
        super.layoutSubviews()

        previewImageView.bounds.size = aspectFitSize(forContentOfSize: CGSize(width: 1920, height: 1080), inBounds: rotationAdjustedBounds().size)
        previewImageView.center = self.boundsCenter
    }

    func playInitially() {

        self.player?.play()

        UIView.animateWithDuration(0.35) {

            self.previewImageView.alpha = 0
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {


        print("KEYPATH: \(keyPath) of OBJECT \(object) with CHANGE \(change)")

//        if keyPath == "rate" {
//            if player?.rate != 0 {
//
//                print("RATE \(self.player!.rate)")
//
//                previewImageView.alpha = 0
//            }
//        }
//        else if keyPath == "status" {
//
//            let status = (self.player!.status == .ReadyToPlay)  ? "ReadyToPlay" : "None"
//            print("STATUS \(status)")
//        }
    }
}
