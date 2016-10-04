//
//  ViewController.swift
//  Example
//
//  Created by Rui Peres on 05/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

extension UIImageView: DisplaceableView {}

class ViewController: UIViewController, GalleryItemsDatasource, GalleryDisplacedViewsDatasource {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!

    var imageViews: [UIImageView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        imageViews += [image1, image2, image3, image4, image5, image6, image7]
    }

    @IBAction func showGalleryImageViewer(sender: UITapGestureRecognizer) {

        guard let displacedView = sender.view as? UIImageView else { return }

        guard let displacedViewIndex = imageViews.indexOf(displacedView) else { return }

        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: imageViews.count)
        let footerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: imageViews.count)

        let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDatasource: self, displacedViewsDatasource: self, configuration: galleryConfiguration())
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView

        galleryViewController.launchedCompletion = {
            print("LAUNCHED")
        }
        galleryViewController.closedCompletion = { print("CLOSED")
        }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED")
        }

        galleryViewController.landedPageAtIndexCompletion = { index in

            print("LANDED AT INDEX: \(index)")

            headerView.currentIndex = index
            footerView.currentIndex = index
        }

        self.presentImageGallery(galleryViewController)
    }

    func itemCount() -> Int {

        return imageViews.count
    }

    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {

        return imageViews[index] ?? nil
    }

    func provideGalleryItem(index: Int) -> GalleryItem {

        if index == 2 {

            return GalleryItem.Video(fetchPreviewImageBlock: { $0(UIImage(named: "2")!)} , videoURL: NSURL(string: "http://video.dailymail.co.uk/video/mol/test/2016/09/21/5739239377694275356/1024x576_MP4_5739239377694275356.mp4")!)
        }
        else {

            let image = imageViews[index].image ?? UIImage(named: "0")!
            
            return GalleryItem.Image { $0(image) }
        }
    }

    func galleryConfiguration() -> GalleryConfiguration {

        return [

            GalleryConfigurationItem.PagingMode(.Standard),
            GalleryConfigurationItem.PresentationStyle(.Displacement),
            GalleryConfigurationItem.HideDecorationViewsOnLaunch(false),

            GalleryConfigurationItem.OverlayColor(UIColor(white: 0.035, alpha: 1)),
            GalleryConfigurationItem.OverlayColorOpacity(1),
            GalleryConfigurationItem.OverlayBlurOpacity(1),
            GalleryConfigurationItem.OverlayBlurStyle(UIBlurEffectStyle.Light),

            GalleryConfigurationItem.MaximumZoolScale(8),
            GalleryConfigurationItem.SwipeToDismissThresholdVelocity(500),

            GalleryConfigurationItem.DoubleTapToZoomDuration(0.15),

            GalleryConfigurationItem.BlurPresentDuration(0.5),
            GalleryConfigurationItem.BlurPresentDelay(0),
            GalleryConfigurationItem.ColorPresentDuration(0.25),
            GalleryConfigurationItem.ColorPresentDelay(0),

            GalleryConfigurationItem.BlurDismissDuration(0.1),
            GalleryConfigurationItem.BlurDismissDelay(0.4),
            GalleryConfigurationItem.ColorDismissDuration(0.45),
            GalleryConfigurationItem.ColorDismissDelay(0),

            GalleryConfigurationItem.ItemFadeDuration(0.3),
            GalleryConfigurationItem.DecorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.RotationDuration(0.15),

            GalleryConfigurationItem.DisplacementDuration(0.55),
            GalleryConfigurationItem.ReverseDisplacementDuration(0.25),
            GalleryConfigurationItem.DisplacementTransitionStyle(.SpringBounce(0.7)),
            GalleryConfigurationItem.DisplacementTimingCurve(.Linear),

            GalleryConfigurationItem.StatusBarHidden(true),
            GalleryConfigurationItem.DisplacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.DisplacementInsetMargin(50)
        ]
    }
}
