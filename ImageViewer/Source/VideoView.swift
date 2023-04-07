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

    var image: UIImage?
    var player: AVPlayer? {
        didSet {
            if  let player = self.player,
                let videoLayer = self.layer as? AVPlayerLayer {
                videoLayer.player = player
                videoLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            }
        }
    }

    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
}
