//
//  VideoViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


class VideoViewController: UIViewController, ItemController {

    let index: Int
    var isInitialController = false

    let player: AVPlayer
    let videoView: VideoView

    init(index: Int, video: NSURL, displacedViewsDatasource: GalleryDisplacedViewsDatasource?, configuration: GalleryConfiguration) {

        self.index = index

        player = AVPlayer(playerItem: AVPlayerItem(URL: video))
        videoView = VideoView(player: player)

        super.init(nibName: nil, bundle: nil)

        player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: "status")
    }

    @available (iOS, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(videoView)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        player.play()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        player.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoView.frame = self.view.bounds
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
/*
        switch player.status {

        case .Unknown :
            print("UNKNOWN")

        case .ReadyToPlay:
            print("READY")

        case .Failed:
            print("FAILED")
        }

        player.seekToTime(kCMTimeZero)
        player.play()
 */
    }

    func presentItem(alongsideAnimation alongsideAnimation: Duration -> Void) {
        
    }
    
    func dismissItem(alongsideAnimation alongsideAnimation: () -> Void, completion: () -> Void) {
        
    }
}
