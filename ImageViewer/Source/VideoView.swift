//
//  VideoView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 25/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVFoundation
import ImageViewer

class VideoView: UIView {

    let previewImageView = UIImageView()
    var image: UIImage? { didSet { previewImageView.image = image } }
    var mediaPlayer: MediaPlayer? {

        willSet {

            if newValue == nil {
                NotificationCenter.default.removeObserver(self)
//                player?.removeObserver(self, forKeyPath: "status")
//                player?.removeObserver(self, forKeyPath: "rate")
            }
        }

        didSet {

            if  let player = self.mediaPlayer,
                let videoLayer = self.layer as? AVPlayerLayer {

                videoLayer.player = mediaPlayer?.avPlayer
                videoLayer.videoGravity = AVLayerVideoGravityResizeAspect

                NotificationCenter.default.addObserver(self, selector: #selector(playerChanged), name: MediaPlayer.Notification.rate, object: player.avPlayer)
                NotificationCenter.default.addObserver(self, selector: #selector(playerChanged), name: MediaPlayer.Notification.status, object: player.avPlayer)
//                player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
//                player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
            }
        }
    }

    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(previewImageView)

        previewImageView.contentMode = .scaleAspectFill
        previewImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewImageView.clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
//        player?.removeObserver(self, forKeyPath: "status")
//        player?.removeObserver(self, forKeyPath: "rate")
    }

    @objc func playerChanged() {
        if let status = self.mediaPlayer?.avPlayer.status, let rate = self.mediaPlayer?.avPlayer.rate  {
            
            if status == .readyToPlay && rate != 0 {
                
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    
                    if let strongSelf = self {
                        
                        strongSelf.previewImageView.alpha = 0
                    }
                })
            }
        }
    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//
//        if let status = self.player?.status, let rate = self.player?.rate  {
//
//            if status == .readyToPlay && rate != 0 {
//
//                UIView.animate(withDuration: 0.3, animations: { [weak self] in
//
//                    if let strongSelf = self {
//
//                        strongSelf.previewImageView.alpha = 0
//                    }
//                })
//            }
//        }
//    }
}
