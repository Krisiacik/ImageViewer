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

    init(index: Int, itemCount: Int, previewImage: UIImage, videoURL: NSURL, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.videoURL = videoURL

        super.init(index: index, itemCount: itemCount, configuration: configuration, isInitialController: isInitialController)

        self.itemView.image = previewImage
    }

    override func didFinishPresentingItem() {
        super.didFinishPresentingItem()

        let player = AVPlayer(URL: self.videoURL)
        self.itemView.player = player
        player.play()
    }
}