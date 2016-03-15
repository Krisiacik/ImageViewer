//
//  GalleryViewControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 05/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryViewControllerDelegate: NSObject, UIPageViewControllerDelegate {
    
//    var newCurrentIndex: Int = 0
//    
//    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//
////        print("******************")
////        print("FINISHED: \(finished)")
////        print("COMPLETED: \(completed)")
//        
//        previousViewControllers.forEach { controller in
//            
//            if let imageController  = controller as? ImageViewController {
//                
////                print("PREVIOUS CONTROLLER INDEX: \(imageController.index)")
//            }
//        }
//        
//        pageViewController.viewControllers?.forEach { controller in
// 
//            if let imageController  = controller as? ImageViewController {
//                
////                print("PAGER CONTROLLER INDEX: \(imageController.index)")
//            }
//        }
//        
//        if let pageController = pageViewController as? GalleryViewController {
//            
//            if completed {
//                if let imageController = pageViewController.viewControllers?.first as? ImageViewController {
//                        newCurrentIndex =  imageController.index
//                }
//            }
//            else {
//                if let imageController = previousViewControllers.first as? ImageViewController  {
//                        newCurrentIndex =  imageController.index
//                }
//            }
//            
//            pageController.currentIndex = newCurrentIndex
//            pageController.landedPageAtIndexCompletion?(newCurrentIndex - 1)
//        }
//    }
}
