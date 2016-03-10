//
//  GalleryViewControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 05/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryViewControllerDelegate: NSObject, UIPageViewControllerDelegate {

    //    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
    ////         print("WILL TRANSITION")
    //
    ////        let pending = pendingViewControllers.first as! ImageViewController
    ////        print("PENDING INDEX: \(pending.index)")
    //    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        print("VIEWCONTROLLERS: \(pageViewController.viewControllers!)")
        pageViewController.viewControllers!.forEach { controller in
            
            let vc = controller as! ImageViewController
            print("IMAGE VC INDEX: \(vc.index)")
        }

        print("*******")
        
//            if let imageController = pageViewController.childViewControllers.first as? ImageViewController,
//                pageController = pageViewController as? GalleryViewController {
//                    
//                    pageController.landedPageAtIndexCompletion?(imageController.index)
//        }
    }
}