//
//  GalleryViewControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 05/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryViewControllerDelegate: NSObject, UIPageViewControllerDelegate {

        func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
//             print("WILL TRANSITION")
    
            print("PENDING")
            pendingViewControllers.forEach { controller in
                
                let vc = controller as! ImageViewController
                
                print("CONTROLLER INDEX \(vc.index)")
            }
        }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }
}