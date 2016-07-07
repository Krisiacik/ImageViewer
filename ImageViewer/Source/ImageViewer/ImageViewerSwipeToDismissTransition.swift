//
//  ImageViewerSwipeToDismissTransition.swift
//  ImageViewer
//
//  Created by Michael Brown on 09/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import Foundation
import UIKit

final class ImageViewerSwipeToDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var verticalTouchPoint: CGFloat = 0
    private var targetOffset: CGFloat = 0
    private var verticalVelocity: CGFloat = 0
    
    func setParameters(verticalTouchPoint: CGFloat, targetOffset: CGFloat, verticalVelocity: CGFloat) {
        self.verticalTouchPoint = verticalTouchPoint
        self.targetOffset = targetOffset
        self.verticalVelocity = verticalVelocity
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return NSTimeInterval(fabs(targetOffset - verticalTouchPoint) / fabs(verticalVelocity))
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        if let imageViewer = fromViewController as? ImageViewerController {
            imageViewer.swipeToDismissAnimation(withVerticalTouchPoint: verticalTouchPoint,
                targetOffset: targetOffset,
                verticalVelocity: verticalVelocity,
                completion: { (finished) -> Void in
                    transitionContext.completeTransition(finished)
            })
        }
    }
}