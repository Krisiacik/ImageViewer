//
//  GalleryViewModel.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public class GalleryViewModel {
    
    let imageProvider: ImageProvider
    let displacedView: UIView
    let imageCount: Int
    let startIndex: Int
    public var landedPageAtIndexCompletion: ((Int) -> Void)? //called everytime ANY animation stops in the page controller and a page at index is on screen
    public var changedPageToIndexCompletion: ((Int) -> Void)? //called after any animation IF & ONLY there is a change in page index compared to before animations started
    
    var displacedImage: UIImage {
        
        let image: UIImage
        
        UIGraphicsBeginImageContextWithOptions(displacedView.bounds.size, true, UIScreen.mainScreen().scale)
        displacedView.drawViewHierarchyInRect(displacedView.bounds, afterScreenUpdates: false)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public init(imageProvider: ImageProvider, imageCount: Int, displacedView: UIView,  displacedViewIndex: Int) {
        
        self.imageProvider = imageProvider
        self.displacedView = displacedView
        self.imageCount = imageCount
        self.startIndex = displacedViewIndex
    }
    
    func fetchImage(atIndex: Int, completion: UIImage? -> Void) {
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        
        dispatch_async(backgroundQueue) {
            
            self.imageProvider.provideImage(atIndex: atIndex, completion: completion)
        }
    }
}