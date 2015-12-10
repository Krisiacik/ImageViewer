//
//  ImageViewerDismissTransition.swift
//  ImageViewer
//
//  Created by Michael Brown on 09/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

class ImageViewerDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: NSTimeInterval
    
    init(duration: NSTimeInterval) {
        self.duration = duration
    }
    
    // MARK: UIViewControllerAnimatedTransitioning
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        if let imageViewer = fromViewController as? ImageViewer {
            imageViewer.closeAnimation(self.duration, completion: {(finished) -> Void in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
