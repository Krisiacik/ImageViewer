//
//  ImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/08/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVFoundation


extension VideoView: ItemView {}

class VideoViewController: ItemBaseController<VideoView> {

    private let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6

    let videoURL: NSURL
    let player: AVPlayer
    unowned let scrubber: VideoScrubber

    let fullHDScreenSize = CGSize(width: 1920, height: 1080)
    let embeddedPlayButton = UIButton.circlePlayButton(70)

    init(index: Int, itemCount: Int, previewImage: UIImage, videoURL: NSURL, scrubber: VideoScrubber, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.videoURL = videoURL
        self.scrubber = scrubber
        self.player = AVPlayer(URL: self.videoURL)

        super.init(index: index, itemCount: itemCount, configuration: configuration, isInitialController: isInitialController)

        self.itemView.image = previewImage
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if isInitialController == true { embeddedPlayButton.alpha = 0 }

        embeddedPlayButton.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleRightMargin]
        self.view.addSubview(embeddedPlayButton)
        embeddedPlayButton.center = self.view.boundsCenter

        embeddedPlayButton.addTarget(self, action: #selector(playVideoInitially), forControlEvents: UIControlEvents.TouchUpInside)

        self.itemView.player = player
        self.itemView.contentMode = .ScaleAspectFill
    }

    override func viewWillAppear(animated: Bool) {

        self.player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
        self.player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)

        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(animated: Bool) {

        self.player.removeObserver(self, forKeyPath: "status")
        self.player.removeObserver(self, forKeyPath: "rate")

        UIApplication.sharedApplication().endReceivingRemoteControlEvents()

        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        self.player.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        itemView.bounds.size = aspectFitSize(forContentOfSize: fullHDScreenSize, inBounds: self.scrollView.bounds.size)
    }

    func playVideoInitially() {

        self.player.play()


        UIView.animateWithDuration(0.25, animations: { [weak self] in

            self?.embeddedPlayButton.alpha = 0

        }) { [weak self] _ in

            self?.embeddedPlayButton.hidden = true
        }
    }

    func closeDecorationViews(duration: NSTimeInterval) {

        UIView.animateWithDuration(duration) { [weak self] in

            self?.embeddedPlayButton.alpha = 0
            self?.itemView.previewImageView.alpha = 1
        }
    }

    override func presentItem(alongsideAnimation alongsideAnimation: () -> Void, completion: () -> Void) {

        let circleButtonAnimation = {

            UIView.animateWithDuration(0.15) { [weak self] in
                self?.embeddedPlayButton.alpha = 1
            }
        }

        super.presentItem(alongsideAnimation: alongsideAnimation) {

            circleButtonAnimation()
            completion()
        }
    }

    override func displacementTargetSize(forSize size: CGSize) -> CGSize {

        return aspectFitSize(forContentOfSize: fullHDScreenSize, inBounds: rotationAdjustedBounds().size)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if keyPath == "rate" || keyPath == "status" {

            fadeOutEmbeddedPlayButton()
        }

        else if keyPath == "contentOffset" {

            handleSwipeToDismissTransition()
        }

        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }

    func handleSwipeToDismissTransition() {

        guard let _ = swipingToDismiss else { return }
        
        embeddedPlayButton.center.y = view.center.y - scrollView.contentOffset.y
    }

    func fadeOutEmbeddedPlayButton() {

        if player.isPlaying() && embeddedPlayButton.alpha != 0  {

            UIView.animateWithDuration(0.3) { [weak self] in

                self?.embeddedPlayButton.alpha = 0
            }
        }
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {

        if let event = event {
            
            if event.type == UIEventType.RemoteControl {
                
                switch event.subtype {

                case .RemoteControlTogglePlayPause:

                    if self.player.isPlaying()  {

                        self.player.pause()
                    }
                    else {

                        self.player.play()
                    }

                case .RemoteControlPause:

                    self.player.pause()

                case .RemoteControlPlay:

                    self.player.play()

                case .RemoteControlPreviousTrack:

                    self.player.pause()
                    self.player.seekToTime(CMTime(value: 0, timescale: 1))
                    self.player.play()

                default:

                    break
                }
            }
        }
    }
}