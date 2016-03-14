//
//  GalleryViewControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 05/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryViewControllerDelegate: NSObject, UIPageViewControllerDelegate {
    
    var newCurrentIndex: Int = 0
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let pageController = pageViewController as? GalleryViewController {
            
            if completed {
                if let imageController = pageViewController.viewControllers?.first as? ImageViewController {
                        newCurrentIndex =  imageController.index
                }
            }
            else {
                if let imageController = previousViewControllers.first as? ImageViewController  {
                        newCurrentIndex =  imageController.index
                }
            }
            
            pageController.currentIndex = newCurrentIndex
            pageController.landedPageAtIndexCompletion?(newCurrentIndex)
        }
    }
}
