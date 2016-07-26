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

        if index == 2 {

            return GalleryItem.Video(NSURL(string: "http://video.dailymail.co.uk/video/mol/2016/07/15/1458458950652835194/1024x576_1458458950652835194.mp4")!)
        }
        else {

            let image = images[index].image ?? UIImage(named: "0")!

            return GalleryItem.Image { $0(image) }
        }
    }
}

func galleryConfiguration() -> GalleryConfiguration {

    return [

        GalleryConfigurationItem.PagingMode(.Standard),
        GalleryConfigurationItem.PresentationStyle(.Displacement),
        GalleryConfigurationItem.HideDecorationViewsOnLaunch(false),

        GalleryConfigurationItem.OverlayColor(UIColor.blackColor()),
        GalleryConfigurationItem.OverlayColorOpacity(0),
        GalleryConfigurationItem.OverlayBlurOpacity(1),
        GalleryConfigurationItem.OverlayBlurStyle(UIBlurEffectStyle.Light),
        GalleryConfigurationItem.OverlayAccelerationFactor(1),

        GalleryConfigurationItem.MaximumZoolScale(8),
        GalleryConfigurationItem.SwipeToDismissThresholdVelocity(500),

        GalleryConfigurationItem.DoubleTapToZoomDuration(0.15),
        GalleryConfigurationItem.BlurLayerDuration(3),
        GalleryConfigurationItem.BlurLayerDelay(0.3),
        GalleryConfigurationItem.ColorLayerDuration(0.4),
        GalleryConfigurationItem.ColorLayerDelay(0.3),
        GalleryConfigurationItem.ItemFadeDuration(0.3),
        GalleryConfigurationItem.DecorationViewsFadeDuration(0.3),
        GalleryConfigurationItem.RotationDuration(0.15),

        GalleryConfigurationItem.DisplacementDuration(0.3),
        GalleryConfigurationItem.DisplacementTransitionStyle(.Normal),
        GalleryConfigurationItem.DisplacementTimingCurve(.Linear),
    ]
}







