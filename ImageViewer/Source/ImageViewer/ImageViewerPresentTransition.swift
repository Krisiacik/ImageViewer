//
//  ImageViewerPresentTransition.swift
//  ImageViewer
//
//  Created by Michael Brown on 07/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

class ImageViewerPresentTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {

    private let sourceView: UIView
    private let duration: NSTimeInterval

    init(sourceView: UIView, duration: NSTimeInterval) {
        self.sourceView = sourceView
        self.duration = duration
    }
    
// MARK: UIViewControllerTransitioningDelegate
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
// MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        toViewController.view.frame = UIScreen.mainScreen().bounds
        container?.addSubview(toViewController.view)
        
        if let imageViewer = toViewController as? ImageViewer {
            imageViewer.showAnimation(self.duration, completion: {(finished) -> Void in
                transitionContext.completeTransition(finished)
            })
        }
    }
}

