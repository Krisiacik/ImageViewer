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
    
    fileprivate var verticalTouchPoint: CGFloat = 0
    fileprivate var targetOffset: CGFloat = 0
    fileprivate var verticalVelocity: CGFloat = 0
    
    func setParameters(_ verticalTouchPoint: CGFloat, targetOffset: CGFloat, verticalVelocity: CGFloat) {
        self.verticalTouchPoint = verticalTouchPoint
        self.targetOffset = targetOffset
        self.verticalVelocity = verticalVelocity
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(fabs(targetOffset - verticalTouchPoint) / fabs(verticalVelocity))
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
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
