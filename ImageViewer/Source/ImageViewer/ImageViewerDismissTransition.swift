//
//  ImageViewerDismissTransition.swift
//  ImageViewer
//
//  Created by Michael Brown on 09/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

final class ImageViewerDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration: NSTimeInterval
    
    init(duration: NSTimeInterval) {
        self.duration = duration
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        if let imageViewer = fromViewController as? ImageViewerController {
            imageViewer.closeAnimation(duration, completion: {(finished) -> Void in
                transitionContext.completeTransition(finished)
            })
        }
    }
}