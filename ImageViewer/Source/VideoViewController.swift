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

class VideoViewController: ItemBaseController<VideoView> {

    private let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6

    let videoURL: NSURL
    let videoPlayer: AVPlayer
    let fullHDScreenSize = CGSize(width: 1920, height: 1080)
    let embeddedPlayButton = UIButton.circlePlayButton(70)

    init(index: Int, itemCount: Int, previewImage: UIImage, videoURL: NSURL, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.videoURL = videoURL
        self.videoPlayer = AVPlayer(URL: self.videoURL)

        super.init(index: index, itemCount: itemCount, configuration: configuration, isInitialController: isInitialController)

        self.itemView.image = previewImage
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        embeddedPlayButton.alpha = 0
        embeddedPlayButton.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleBottomMargin, .FlexibleRightMargin]
        self.view.addSubview(embeddedPlayButton)
        embeddedPlayButton.center = self.view.boundsCenter

        embeddedPlayButton.addTarget(self, action: #selector(playVideoInitially), forControlEvents: UIControlEvents.TouchUpInside)

        self.itemView.player = videoPlayer
        self.itemView.contentMode = .ScaleAspectFill
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    func playVideoInitially() {

        self.videoPlayer.play()

        self.itemView.previewImageView.hidden = true

        UIView.animateWithDuration(0.25, animations: { [weak self] in

            self?.embeddedPlayButton.alpha = 0

        }) { [weak self] _ in

            self?.embeddedPlayButton.hidden = true
        }
    }

    func closeDecorationViews(duration: NSTimeInterval) {


        UIView.animateWithDuration(duration) { [weak self] in

            self?.embeddedPlayButton.alpha = 0
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

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

         self.videoPlayer.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        itemView.bounds.size = aspectFitSize(forContentOfSize: fullHDScreenSize, inBounds: self.scrollView.bounds.size)
    }

    override func displacementTargetSize(forSize size: CGSize) -> CGSize {

        return aspectFitSize(forContentOfSize: fullHDScreenSize, inBounds: rotationAdjustedBounds().size)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        guard let swipingToDissmissInProgress = swipingToDismiss else { return }
        guard keyPath == "contentOffset" else { return }

        let distanceToEdge: CGFloat
        let percentDistance: CGFloat

        switch swipingToDissmissInProgress {

        case .Horizontal:

            distanceToEdge = (scrollView.bounds.width / 2) + (itemView.bounds.width / 2)
            percentDistance = fabs(scrollView.contentOffset.x / distanceToEdge)

        case .Vertical:

            distanceToEdge = (scrollView.bounds.height / 2) + (itemView.bounds.height / 2)
            percentDistance = fabs(scrollView.contentOffset.y / distanceToEdge)
        }

        embeddedPlayButton.alpha =  1 - percentDistance * swipeToDismissFadeOutAccelerationFactor

        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }
}