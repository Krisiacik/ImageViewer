//
//  ImageViewerPresentTransition.swift
//  ImageViewer
//
//  Created by Michael Brown on 07/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

final class ImageViewerPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {

    fileprivate let duration: TimeInterval

    init(duration: TimeInterval) {
        self.duration = duration
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        toViewController.view.frame = UIScreen.main.bounds
        container.addSubview(toViewController.view)
        
        if let imageViewer = toViewController as? ImageViewerController {
            imageViewer.showAnimation(duration, completion: {(finished) -> Void in
                transitionContext.completeTransition(finished)
            })
        }
    }
}

