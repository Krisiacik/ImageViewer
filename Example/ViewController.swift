//
//  ViewController.swift
//  Example
//
//  Created by Rui Peres on 05/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GalleryItemsDatasource, GalleryDisplacedViewsDatasource {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!

    var images: [UIImageView] = []


    override func viewDidLoad() {
        super.viewDidLoad()

        images += [image1, image2, image3, image4, image5, image6, image7]
    }

    @IBAction func showGalleryImageViewer(sender: UITapGestureRecognizer) {

        guard let displacedView = sender.view as? UIImageView else { return }
        guard let displacedViewIndex = images.indexOf(displacedView) else { return }

        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: images.count)
//        let footerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: images.count)

        let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDatasource: self, displacedViewsDatasource: self, configuration: galleryConfiguration())
        galleryViewController.headerView = headerView
//        galleryViewController.footerView = footerView

        galleryViewController.launchedCompletion = {
            //print("LAUNCHED") 
        }
        galleryViewController.closedCompletion = { //print("CLOSED") 
        }
        galleryViewController.swipedToDismissCompletion = { //print("SWIPE-DISMISSED") 
        }

        galleryViewController.landedPageAtIndexCompletion = { index in

            //print("LANDED AT INDEX: \(index)")

            headerView.currentIndex = index
            //footerView.currentIndex = index
        }

        self.presentImageGallery(galleryViewController)
    }

    func itemCount() -> Int {

        return images.count
    }

    func provideDisplacementItem(atIndex index: Int) -> UIView? {

        return images[index] ?? nil
    }

    func provideGalleryItem(index: Int) -> GalleryItem {


//        let image = images[index].image ?? UIImage(named: "0")!
//
//        return GalleryItem.Image { $0(image) }
//    }

        if index == 2 {

            return GalleryItem.Video(previewImage: UIImage(named: "2")!, videoURL: NSURL(string: "http:video.dailymail.co.uk/video/mol/2016/07/15/1458458950652835194/1024x576_1458458950652835194.mp4")!)
        }
        else {

            let image = images[index].image ?? UIImage(named: "0")!
            
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

            GalleryConfigurationItem.StatusBarHidden(true)
        ]
    }
}
