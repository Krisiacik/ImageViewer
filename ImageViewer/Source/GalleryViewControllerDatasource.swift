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

    init(viewModel: GalleryViewModel) {
        
        self.viewModel = viewModel
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        guard let currentController = viewController as? ImageViewController else { return nil }
        guard currentController.index > 0 else { return nil }
        
        let nextIndex = currentController.index - 1
        
        return ImageViewController(imageViewModel: self.viewModel , imageIndex: nextIndex, showDisplacedImage: (nextIndex == self.viewModel.startIndex))
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        guard let currentController = viewController as? ImageViewController  else { return nil }
        guard currentController.index < viewModel.imageCount - 1 else { return nil }
        
        let nextIndex = currentController.index + 1
        
        return ImageViewController(imageViewModel: self.viewModel , imageIndex: nextIndex, showDisplacedImage: (nextIndex == self.viewModel.startIndex))
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