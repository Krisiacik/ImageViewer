//
//  GalleryCloseTransition.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class GalleryCloseTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: NSTimeInterval
    
    init(duration: NSTimeInterval) {
        
        self.duration = duration
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let transitionContainerView = transitionContext.containerView()!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        transitionContainerView.addSubview(fromViewController.view)
        
        UIView.animateWithDuration(self.duration, delay: 0, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            
            /// Transition the frontend to full clear
            fromViewController.view.alpha = 1.0
            
            }) { finished in
                
                transitionContext.completeTransition(finished)
        }
    }
}