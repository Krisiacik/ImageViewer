//
//  VideoRawViewController.swift
//  ImageViewer
//
//  Created by Sameh sayed on 4/3/20.
//  Copyright © 2020 MailOnline. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class VideoRawViewController: ItemBaseController<VideoView> {

    fileprivate let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6


    var fetchVideoBlock:FetchVideoBlock?

    var player: AVPlayer?
    unowned let scrubber: VideoScrubber

    let fullHDScreenSizeLandscape = CGSize(width: 1920, height: 1080)
    let fullHDScreenSizePortrait = CGSize(width: 1080, height: 1920)
    let embeddedPlayButton = UIButton.circlePlayButton(70)

    private var autoPlayStarted: Bool = false
    private var autoPlayEnabled: Bool = false

    init(index: Int, itemCount: Int, fetchImageBlock: @escaping FetchImageBlock, fetchVideoBlock: @escaping FetchVideoBlock, scrubber: VideoScrubber, configuration: GalleryConfiguration, isInitialController: Bool = false)
    {
        self.fetchVideoBlock = fetchVideoBlock
        self.scrubber = scrubber

        for item in configuration {

            switch item {

            case .videoAutoPlay(let enabled):
                autoPlayEnabled = enabled

            default: break
            }
        }
            super.init(index: index, itemCount: itemCount, fetchImageBlock: fetchImageBlock, configuration: configuration, isInitialController: isInitialController)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()

        if isInitialController == true { embeddedPlayButton.alpha = 0 }
    }

    public func fetchVideo() {
        activityIndicatorView.startAnimating()

        fetchVideoBlock? { [weak self] video in

            if let video = video {

                DispatchQueue.main.async {
                    guard let S = self else { return }

                    self?.activityIndicatorView.stopAnimating()
                    self?.player = AVPlayer(playerItem: AVPlayerItem(asset: video))
                    self?.embeddedPlayButton.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
                    self?.view.addSubview(self!.embeddedPlayButton)
                    self?.embeddedPlayButton.center = S.view.boundsCenter
                    self?.embeddedPlayButton.addTarget(self, action: #selector(self?.playVideoInitially), for: UIControl.Event.touchUpInside)
                    self?.itemView.player = self?.player
                    self?.itemView.contentMode = .scaleAspectFill

                    self?.view.setNeedsLayout()
                    self?.view.layoutIfNeeded()
                    self?.performAutoPlay()
                    self?.scrubber.player = self?.player


                        self?.player?.addObserver(S, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
                        self?.player?.addObserver(S, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        if player != nil {
            self.player?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
            self.player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
        }
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if player != nil {
            self.player?.removeObserver(self, forKeyPath: "status")
            self.player?.removeObserver(self, forKeyPath: "rate")
        }
        UIApplication.shared.endReceivingRemoteControlEvents()

        super.viewWillDisappear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if player == nil {
            fetchVideo()
        }else{
            self.performAutoPlay()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.player?.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let isLandscape = itemView.bounds.width >= itemView.bounds.height
        itemView.bounds.size = aspectFitSize(forContentOfSize: isLandscape ? fullHDScreenSizeLandscape : fullHDScreenSizePortrait, inBounds: self.scrollView.bounds.size)
        itemView.center = scrollView.boundsCenter
    }

    @objc func playVideoInitially() {

        self.player?.play()


        UIView.animate(withDuration: 0.25, animations: { [weak self] in

            self?.embeddedPlayButton.alpha = 0

        }, completion: { [weak self] _ in

            self?.embeddedPlayButton.isHidden = true
        })
    }

    override func closeDecorationViews(_ duration: TimeInterval) {

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

        let isLandscape = itemView.bounds.width >= itemView.bounds.height
        return aspectFitSize(forContentOfSize: isLandscape ? fullHDScreenSizeLandscape : fullHDScreenSizePortrait, inBounds: rotationAdjustedBounds().size)
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

        if (player?.isPlaying() ?? false) && embeddedPlayButton.alpha != 0  {

            UIView.animate(withDuration: 0.3, animations: { [weak self] in

                self?.embeddedPlayButton.alpha = 0
            })
        }
    }

    override func remoteControlReceived(with event: UIEvent?) {

        if let event = event {

            if event.type == UIEvent.EventType.remoteControl {

                switch event.subtype {

                case .remoteControlTogglePlayPause:

                    if (self.player?.isPlaying() ?? false)  {

                        self.player?.pause()
                    }
                    else {

                        self.player?.play()
                    }

                case .remoteControlPause:

                    self.player?.pause()

                case .remoteControlPlay:

                    self.player?.play()

                case .remoteControlPreviousTrack:

                    self.player?.pause()
                    self.player?.seek(to: CMTime(value: 0, timescale: 1))
                    self.player?.play()

                default:

                    break
                }
            }
        }
    }

    private func performAutoPlay() {
        guard autoPlayEnabled else { return }
        guard autoPlayStarted == false else { return }

        autoPlayStarted = true
        embeddedPlayButton.isHidden = true
        scrubber.play()
    }
}
