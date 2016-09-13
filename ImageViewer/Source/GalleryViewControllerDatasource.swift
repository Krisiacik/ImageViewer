//
//  GaleryViewControllerDatasource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class GalleryViewControllerDatasource: NSObject, UIPageViewControllerDataSource {
    
    fileprivate let imageControllerFactory: ImageViewControllerFactory
    fileprivate let imageCount: Int
    fileprivate let galleryPagingMode: GalleryPagingMode
    
    init(imageControllerFactory: ImageViewControllerFactory, imageCount: Int, galleryPagingMode: GalleryPagingMode) {
        
        self.imageControllerFactory = imageControllerFactory
        self.imageCount = imageCount
        self.galleryPagingMode =  (imageCount > 1) ? galleryPagingMode : GalleryPagingMode.standard
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentController = viewController as? ImageViewController else { return nil }
        let previousIndex = (currentController.index == 0) ? imageCount - 1 : currentController.index - 1
        
        switch galleryPagingMode {
            
        case .standard:
            return (currentController.index > 0) ? imageControllerFactory.createImageViewController(previousIndex) : nil
            
        case .carousel:
            return imageControllerFactory.createImageViewController(previousIndex)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentController = viewController as? ImageViewController  else { return nil }
        let nextIndex = (currentController.index == imageCount - 1) ? 0 : currentController.index + 1
        
        switch galleryPagingMode {
            
        case .standard:
            return (currentController.index < imageCount - 1) ? imageControllerFactory.createImageViewController(nextIndex) : nil
            
        case .carousel:
            return imageControllerFactory.createImageViewController(nextIndex)
        }
    }
}
