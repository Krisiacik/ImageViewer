//
//  ImageViewerDismissTransition.swift
//  ImageViewer
//
//  Created by Michael Brown on 09/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

final class ImageViewerDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate let duration: TimeInterval
    
    init(duration: TimeInterval) {
        self.duration = duration
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        if let imageViewer = fromViewController as? ImageViewerController {
            imageViewer.closeAnimation(duration, completion: {(finished) -> Void in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
