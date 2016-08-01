//
//  SuperNewImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/08/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVFoundation


extension VideoView: ItemView {}

class SuperNewVideoViewController: ItemBaseController<VideoView> {

    let videoURL: NSURL
    let fullHDScreenSize = CGSize(width: 1920, height: 1080)


    init(index: Int, itemCount: Int, previewImage: UIImage, videoURL: NSURL, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.videoURL = videoURL

        super.init(index: index, itemCount: itemCount, configuration: configuration, isInitialController: isInitialController)

        self.itemView.image = previewImage
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let player = AVPlayer(URL: self.videoURL)
        self.itemView.player = player
        self.itemView.contentMode = .ScaleAspectFill
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

         self.itemView.player?.play()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

         self.itemView.player?.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        itemView.bounds.size = aspectFitSize(forContentOfSize: fullHDScreenSize, inBounds: self.scrollView.bounds.size)
    }

    override func displacementTargetSize(forSize size: CGSize) -> CGSize {

        return aspectFitSize(forContentOfSize: fullHDScreenSize, inBounds: rotationAdjustedBounds().size)
    }
}