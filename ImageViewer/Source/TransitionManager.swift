//
//  TransitionManager.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 03/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

/*

This class decides which animator/interactor is suitable for particular animation or interaction for a particular controller. When view controllers use custom transitions, they outsource the handling of transition itself to an animator/interactor class. View controllers use delegation to ask this class for the right animator/interactor. It serves basically as an animator/interactor factory.
*/

//class TransitionManager: UIViewControllerTransitioningDelegate  {
//    
//    
//    
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        return GalleryPresentTransition(duration: <#T##NSTimeInterval#>, displacedView: <#T##UIView#>)
//    }
//    
//}