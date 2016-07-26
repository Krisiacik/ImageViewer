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

    //let adView: UIView?

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }

    init(player: AVPlayer) {

        super.init(frame: CGRect.zero)

        if let videoLayer = self.layer as? AVPlayerLayer {

            videoLayer.player = player
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspect
        }
    }

    @available (iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {fatalError() }
}
