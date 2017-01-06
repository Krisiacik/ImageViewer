//
//  ViewController.swift
//  Example
//
//  Created by Rui Peres on 05/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

extension UIImageView: DisplaceableView {}

class ViewController: UIViewController {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!
    @IBOutlet weak var image6: UIImageView!
    @IBOutlet weak var image7: UIImageView!

    var imageViews: [UIImageView]              = []
    var items:      [UIImageView: GalleryItem] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        imageViews += [image1, image2, image3, image4, image5, image6, image7]

        for index in 0..<imageViews.count {

            let imageView = imageViews[index]

            switch index {

            case 2:

                items[imageView] = GalleryItem.video(fetchPreviewImageBlock: { $0(UIImage(named: "2")!) }, videoURL: URL (string: "http://video.dailymail.co.uk/video/mol/test/2016/09/21/5739239377694275356/1024x576_MP4_5739239377694275356.mp4")!)

            case 4:

                let myFetchImageBlock: FetchImageBlock = { $0(imageView.image!) }

                let itemViewControllerBlock: ItemViewControllerBlock = { index, itemCount, fetchImageBlock, configuration, isInitialController in

                    return AnimatedViewController(index: index, itemCount: itemCount, fetchImageBlock: myFetchImageBlock, configuration: configuration, isInitialController: isInitialController)
                }

                items[imageView] = GalleryItem.custom(fetchImageBlock: myFetchImageBlock, itemViewControllerBlock: itemViewControllerBlock)

            default:

                let image = imageView.image ?? UIImage(named: "0")!
                items[imageView] = GalleryItem.image { $0(image) }
            }
        }
    }

    @IBAction func showGalleryImageViewer(_ sender: UITapGestureRecognizer) {

        guard let displacedView = sender.view as? UIImageView else { return }

        guard let displacedViewIndex = imageViews.index(of: displacedView) else { return }

        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: imageViews.count)
        let footerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: imageViews.count)

        let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDataSource: self, itemsDelegate: self, displacedViewsDataSource: self, configuration: galleryConfiguration())
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView

        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }

        galleryViewController.landedPageAtIndexCompletion = { index in

            print("LANDED AT INDEX: \(index)")

            headerView.count = self.imageViews.count
            headerView.currentIndex = index
            footerView.count = self.imageViews.count
            footerView.currentIndex = index
        }

        self.presentImageGallery(galleryViewController)
    }

    func galleryConfiguration() -> GalleryConfiguration {

        return [

            GalleryConfigurationItem.closeButtonMode(.builtIn),

            GalleryConfigurationItem.pagingMode(.standard),
            GalleryConfigurationItem.presentationStyle(.displacement),
            GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),

            GalleryConfigurationItem.swipeToDismissMode(.vertical),
            GalleryConfigurationItem.toggleDecorationViewsBySingleTap(false),

            GalleryConfigurationItem.overlayColor(UIColor(white: 0.035, alpha: 1)),
            GalleryConfigurationItem.overlayColorOpacity(1),
            GalleryConfigurationItem.overlayBlurOpacity(1),
            GalleryConfigurationItem.overlayBlurStyle(UIBlurEffectStyle.light),

            GalleryConfigurationItem.maximumZoomScale(8),
            GalleryConfigurationItem.swipeToDismissThresholdVelocity(500),

            GalleryConfigurationItem.doubleTapToZoomDuration(0.15),

            GalleryConfigurationItem.blurPresentDuration(0.5),
            GalleryConfigurationItem.blurPresentDelay(0),
            GalleryConfigurationItem.colorPresentDuration(0.25),
            GalleryConfigurationItem.colorPresentDelay(0),

            GalleryConfigurationItem.blurDismissDuration(0.1),
            GalleryConfigurationItem.blurDismissDelay(0.4),
            GalleryConfigurationItem.colorDismissDuration(0.45),
            GalleryConfigurationItem.colorDismissDelay(0),

            GalleryConfigurationItem.itemFadeDuration(0.3),
            GalleryConfigurationItem.decorationViewsFadeDuration(0.15),
            GalleryConfigurationItem.rotationDuration(0.15),

            GalleryConfigurationItem.displacementDuration(0.55),
            GalleryConfigurationItem.reverseDisplacementDuration(0.25),
            GalleryConfigurationItem.displacementTransitionStyle(.springBounce(0.7)),
            GalleryConfigurationItem.displacementTimingCurve(.linear),

            GalleryConfigurationItem.statusBarHidden(true),
            GalleryConfigurationItem.displacementKeepOriginalInPlace(false),
            GalleryConfigurationItem.displacementInsetMargin(50)
        ]
    }
}

extension ViewController: GalleryDisplacedViewsDataSource {

    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {

        return index < imageViews.count ? imageViews[index] : nil
    }
}

extension ViewController: GalleryItemsDataSource {

    func itemCount() -> Int {

        return imageViews.count
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {

        let imageView = imageViews[index]
        return items[imageView]!
    }
}

extension ViewController: GalleryItemsDelegate {

    func removeGalleryItem(at index: Int) {

        print("remove item at \(index)")

        let imageView = imageViews[index]
        imageView.removeFromSuperview()
        imageViews.remove(at: index)
    }
}

// Some external custom UIImageView we want to show in the gallery
class FLSomeAnimatedImage: UIImageView {
}

// Extend ImageBaseController so we get all the functionality for free
class AnimatedViewController: ItemBaseController<FLSomeAnimatedImage> {
}
