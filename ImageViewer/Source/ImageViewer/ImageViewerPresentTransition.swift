//
//  ImageViewerPresentTransition.swift
//  ImageViewer
//
//  Created by Michael Brown on 07/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

final class ImageViewerPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {

    private let duration: NSTimeInterval

    init(duration: NSTimeInterval) {
        self.duration = duration
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        toViewController.view.frame = UIScreen.mainScreen().bounds
        container?.addSubview(toViewController.view)
        
        if let imageViewer = toViewController as? ImageViewerController {
            imageViewer.showAnimation(duration, completion: {(finished) -> Void in
                transitionContext.completeTransition(finished)
            })
        }
    }
}

