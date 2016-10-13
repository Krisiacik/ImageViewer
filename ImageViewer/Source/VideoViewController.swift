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

    fileprivate let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6

    let videoURL: URL
    let player: AVPlayer
    unowned let scrubber: VideoScrubber

    let fullHDScreenSize = CGSize(width: 1920, height: 1080)
    let embeddedPlayButton = UIButton.circlePlayButton(70)

    init(index: Int, itemCount: Int, fetchImageBlock: @escaping FetchImageBlock, videoURL: URL, scrubber: VideoScrubber, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.videoURL = videoURL
        self.scrubber = scrubber
        self.player = AVPlayer(url: self.videoURL)

        super.init(index: index, itemCount: itemCount, fetchImageBlock: fetchImageBlock, configuration: configuration, isInitialController: isInitialController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if isInitialController == true { embeddedPlayButton.alpha = 0 }

        embeddedPlayButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
        self.view.addSubview(embeddedPlayButton)
        embeddedPlayButton.center = self.view.boundsCenter

        embeddedPlayButton.addTarget(self, action: #selector(playVideoInitially), for: UIControlEvents.touchUpInside)

        self.itemView.player = player
        self.itemView.contentMode = .scaleAspectFill
    }

    override func viewWillAppear(_ animated: Bool) {

        self.player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        self.player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)

        UIApplication.shared.beginReceivingRemoteControlEvents()

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {

        self.player.removeObserver(self, forKeyPath: "status")
        self.player.removeObserver(self, forKeyPath: "rate")

        UIApplication.shared.endReceivingRemoteControlEvents()

        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.player.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        itemView.bounds.size = aspectFitSize(forContentOfSize: fullHDScreenSize, inBounds: self.scrollView.bounds.size)
        itemView.center = scrollView.boundsCenter
    }

    func playVideoInitially() {

        self.player.play()


        UIView.animate(withDuration: 0.25, animations: { [weak self] in

            self?.embeddedPlayButton.alpha = 0

        }, completion: { [weak self] _ in

            self?.embeddedPlayButton.isHidden = true
        }) 
    }

    func closeDecorationViews(_ duration: TimeInterval) {

        UIView.animate(withDuration: duration, animations: { [weak self] in

            self?.embeddedPlayButton.alpha = 0
            self?.itemView.previewImageView.alpha = 1
        }) 
    }

    override func presentItem(alongsideAnimation: () -> Void, completion: @escaping () -> Void) {

        let circleButtonAnimation = {

            UIView.animate(withDuration: 0.15, animations: { [weak self] in
                self?.embeddedPlayButton.alpha = 1
            }) 
        }

        super.presentItem(alongsideAnimation: alongsideAnimation) {

            circleButtonAnimation()
            completion()
        }
    }

    override func displacementTargetSize(forSize size: CGSize) -> CGSize {

        return aspectFitSize(forContentOfSize: fullHDScreenSize, inBounds: rotationAdjustedBounds().size)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == "rate" || keyPath == "status" {

            fadeOutEmbeddedPlayButton()
        }

        else if keyPath == "contentOffset" {

            handleSwipeToDismissTransition()
        }

        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

    func handleSwipeToDismissTransition() {

        guard let _ = swipingToDismiss else { return }
        
        embeddedPlayButton.center.y = view.center.y - scrollView.contentOffset.y
    }

    func fadeOutEmbeddedPlayButton() {

        if player.isPlaying() && embeddedPlayButton.alpha != 0  {

            UIView.animate(withDuration: 0.3, animations: { [weak self] in

                self?.embeddedPlayButton.alpha = 0
            }) 
        }
    }
    
    override func remoteControlReceived(with event: UIEvent?) {

        if let event = event {
            
            if event.type == UIEventType.remoteControl {
                
                switch event.subtype {

                case .remoteControlTogglePlayPause:

                    if self.player.isPlaying()  {

                        self.player.pause()
                    }
                    else {

                        self.player.play()
                    }

                case .remoteControlPause:

                    self.player.pause()

                case .remoteControlPlay:

                    self.player.play()

                case .remoteControlPreviousTrack:

                    self.player.pause()
                    self.player.seek(to: CMTime(value: 0, timescale: 1))
                    self.player.play()

                default:

                    break
                }
            }
        }
    }
}
