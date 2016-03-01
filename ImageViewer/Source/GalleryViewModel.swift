//
//  GalleryViewModel.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryViewModel {
    
    let imageProvider: ImageProvider
    let displacedView: UIView
    let imageCount: Int
    let startIndex: Int
    
    var displacedImage: UIImage {
        
        let image: UIImage
        
        UIGraphicsBeginImageContextWithOptions(displacedView.bounds.size, true, UIScreen.mainScreen().scale)
        displacedView.drawViewHierarchyInRect(displacedView.bounds, afterScreenUpdates: false)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    init(imageProvider: ImageProvider, imageCount: Int, displacedView: UIView,  displacedViewIndex: Int) {
        
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