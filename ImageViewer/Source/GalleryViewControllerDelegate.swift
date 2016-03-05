//
//  GalleryViewControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 05/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryViewControllerDelegate: NSObject, UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let imageController = pageViewController.viewControllers?.first as? ImageViewController,
            pageController = pageViewController as? GalleryViewController {
                
                if imageController.index != pageController.currentIndex {

                    pageController.previousIndex = pageController.currentIndex
                    pageController.currentIndex = imageController.index
                    
                    pageController.changedPageToIndexCompletion?(imageController.index)
                }
                else {
                    pageController.landedPageAtIndexCompletion?(imageController.index)
                }
        }
    }
}