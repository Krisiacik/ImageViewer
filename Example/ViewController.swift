//
//  ViewController.swift
//  Example
//
//  Created by Rui Peres on 05/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GalleryItemsDatasource, GalleryDisplacedViewsDatasource {
    
    @IBOutlet var images: [UIImageView] = []
    
    @IBAction func showGalleryImageViewer(sender: UITapGestureRecognizer) {
        
        guard let displacedView = sender.view as? UIImageView else { return }
        guard let displacedViewIndex = images.indexOf(displacedView) else { return }
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: images.count)
        let footerView = CounterView(frame: frame, currentIndex: displacedViewIndex, count: images.count)
        
        let galleryViewController = NewGalleryViewController(startIndex: displacedViewIndex, itemsDatasource: self, displacedViewsDatasource: self, configuration: galleryConfiguration())
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        
        galleryViewController.landedPageAtIndexCompletion = { index in
            
            print("LANDED AT INDEX: \(index)")
            
            headerView.currentIndex = index
            footerView.currentIndex = index
        }

        self.presentImageGallery(galleryViewController)
    }

    func numberOfItemsInGalery() -> Int {
        
        return images.count
    }

    func provideDisplacementItem(atIndex index: Int) -> UIView? {
        
        return images[index] ?? nil
    }

    func provideGalleryItem(index: Int) -> GalleryItem {

//        if index == 2 {
//
//            return GalleryItem.Video(NSURL(string: "")!)
//        }
//        else {

            let image = images[index].image ?? UIImage(named: "0")!

            return GalleryItem.Image { $0(image) }
//        }
    }
}

func galleryConfiguration() -> GalleryConfiguration {

    let pagingMode                  = GalleryConfigurationItem.PagingMode(GalleryPagingMode.Carousel)
    let presentationStyle           = GalleryConfigurationItem.PresentationStyle(.Displace)
    let displacementDuration        = GalleryConfigurationItem.DisplacementDuration(0.5)
    let displacementBounce          = GalleryConfigurationItem.DisplacementTransitionStyle(.SpringBounce(0.7))
    let displacementCurve           = GalleryConfigurationItem.DisplacementTimingCurve(.EaseOut)
    let overlayColor                = GalleryConfigurationItem.OverlayColor(UIColor.blackColor())
    let colorOpacity                = GalleryConfigurationItem.OverlayColorOpacity(0)
    let blurOpacity                 = GalleryConfigurationItem.OverlayBlurOpacity(0)
    let blurStyle                   = GalleryConfigurationItem.OverlayBlurStyle(UIBlurEffectStyle.Light)
    let overlayAccelerationFactor   = GalleryConfigurationItem.OverlayAccelerationFactor(1)
    let zoomDuration                = GalleryConfigurationItem.DoubleTapToZoomDuration(1)
    let maximumZoomScale            = GalleryConfigurationItem.MaximumZoolScale(8)

    return [pagingMode, maximumZoomScale, zoomDuration, presentationStyle, displacementDuration, displacementCurve, displacementBounce, overlayColor, blurOpacity, colorOpacity, blurStyle, overlayAccelerationFactor]
}
