//
//  GaleryViewControllerDatasource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryViewControllerDatasource: NSObject, UIPageViewControllerDataSource {
    
    let imageControllerFactory: ImageViewControllerFactory
    let viewModel: GalleryViewModel
    let galleryPagingMode: GalleryPagingMode
    
    init(imageControllerFactory: ImageViewControllerFactory, viewModel: GalleryViewModel, galleryPagingMode: GalleryPagingMode) {
        
        self.imageControllerFactory = imageControllerFactory
        self.viewModel = viewModel
        self.galleryPagingMode =  (viewModel.imageCount > 1) ? galleryPagingMode : GalleryPagingMode.Standard
        
        UIDevice.currentDevice().orientation
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        guard let currentController = viewController as? ImageViewController else { return nil }
        let previousIndex = (currentController.index == 0) ? viewModel.imageCount - 1 : currentController.index - 1
        
        switch galleryPagingMode {
            
        case .Standard:
            return (currentController.index > 0) ? imageControllerFactory.createImageViewController(previousIndex) : nil
            
        case .Carousel:
            return imageControllerFactory.createImageViewController(previousIndex)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        guard let currentController = viewController as? ImageViewController  else { return nil }
        let nextIndex = (currentController.index == viewModel.imageCount - 1) ? 0 : currentController.index + 1
        
        switch galleryPagingMode {
            
        case .Standard:
            return (currentController.index < viewModel.imageCount - 1) ? imageControllerFactory.createImageViewController(nextIndex) : nil
            
        case .Carousel:
            return imageControllerFactory.createImageViewController(nextIndex)
        }
    }
}