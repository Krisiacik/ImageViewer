//
//  GaleryViewControllerDatasource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryViewControllerDatasource: NSObject, UIPageViewControllerDataSource {
    
    let viewModel: GalleryViewModel
    let configuration: [GalleryConfiguration]
    weak var fadeInHandler: ImageFadeInHandler?
    weak var imageControllerDelegate: ImageViewControllerDelegate?

    init(viewModel: GalleryViewModel, configuration: [GalleryConfiguration], fadeInHandler: ImageFadeInHandler, imageControllerDelegate: ImageViewControllerDelegate) {
        
        self.viewModel = viewModel
        self.configuration = configuration
        self.fadeInHandler = fadeInHandler
        self.imageControllerDelegate = imageControllerDelegate
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        guard let currentController = viewController as? ImageViewController else { return nil }
        guard currentController.index > 0 else { return nil }
        
        let nextIndex = currentController.index - 1
        
        return ImageViewController(imageViewModel: self.viewModel, configuration: configuration, imageIndex: nextIndex, showDisplacedImage: (nextIndex == self.viewModel.startIndex), fadeInHandler: fadeInHandler, delegate: imageControllerDelegate)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        guard let currentController = viewController as? ImageViewController  else { return nil }
        guard currentController.index < viewModel.imageCount - 1 else { return nil }
        
        let nextIndex = currentController.index + 1
        
        return ImageViewController(imageViewModel: self.viewModel, configuration: configuration, imageIndex: nextIndex, showDisplacedImage: (nextIndex == self.viewModel.startIndex), fadeInHandler: fadeInHandler, delegate: imageControllerDelegate)
    }
    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        
//        return viewModel.imageCount
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        
//        return viewModel.startIndex
//    }
}