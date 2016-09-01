//
//  GalleryCloseTransition.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class GalleryCloseTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: TimeInterval
    
    init(duration: TimeInterval) {
        
        self.duration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let transitionContainerView = transitionContext.containerView
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        transitionContainerView.addSubview(fromViewController.view)
        
        UIView.animate(withDuration: self.duration, delay: 0, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            
            /// Transition the frontend to full clear
            fromViewController.view.alpha = 1.0
            
            }) { finished in
                
                transitionContext.completeTransition(finished)
        }
    }
}
