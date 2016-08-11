//
//  GalleryPresentTransition.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 02/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class GalleryPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {

    var headerView: UIView?
    var footerView: UIView?
    var closeView: UIView?
    var seeAllView: UIView?
    var completion: (() -> Void)?
    private let duration: NSTimeInterval
    private let displacedView: UIView
    private let decorationViewsHidden: Bool
    private let backgroundColor: UIColor

    init(duration: NSTimeInterval, displacedView: UIView, decorationViewsHidden: Bool, backgroundColor: UIColor) {
        self.duration = duration
        self.displacedView = displacedView
        self.decorationViewsHidden = decorationViewsHidden
        self.backgroundColor = backgroundColor
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let originalFrame = displacedView.frame
        let imageView = displacedView as? UIImageView
        let resizeToAspectFit = imageView?.contentMode != .ScaleAspectFit

        if let imageView = imageView where resizeToAspectFit {
            /// Resize the imageView to aspect fit before showing it in the gallery
            UIView.animateWithDuration(0.25, animations: {
                layoutAspectFit(self.displacedView, image: imageView.image!)
                }, completion: { [weak self] finished in
                    self?.animateDisplacedView(transitionContext, onComplete: {
                        self?.displacedView.frame = originalFrame
                    })
                })
        } else {
            self.animateDisplacedView(transitionContext)
        }
    }

    private func animateDisplacedView(transitionContext: UIViewControllerContextTransitioning, onComplete: (Void -> Void)? = nil) {
        /// Get the temporary container view that facilitates all the animations
        let transitionContainerView = transitionContext.containerView()! //Apple, Apple..

        /// Get the target controller's root view and add it to the scene
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        transitionContainerView.addSubview(toViewController.view)

        /// Make it align with scene geometry
        toViewController.view.frame = UIScreen.mainScreen().bounds

        /// Prepare transition of background from transparent to full black
        toViewController.view.backgroundColor = backgroundColor
        toViewController.view.alpha = 0.0

        if isPortraitOnly() {
            toViewController.view.transform = rotationTransform()
            toViewController.view.bounds = rotationAdjustedBounds()
        }

        /// Make a screenshot of displaced view so we can create our own animated view
        let screenshot = screenshotFromView(displacedView)

        /// Make the original displacedView hidden, we can give an illusion it is moving away from its parent view
        displacedView.hidden = true

        /// Hide the gallery views
        headerView?.alpha = 0.0
        footerView?.alpha = 0.0
        closeView?.alpha = 0.0
        seeAllView?.alpha = 0.0

        /// Translate coordinates of displaced view into our coordinate system (which is now the transition container view) so that we match the animation start position on device screen level
        let origin = transitionContainerView.convertPoint(CGPoint.zero, fromView: displacedView)

        /// Create UIImageView with screenshot
        let animatedImageView = UIImageView()
        animatedImageView.bounds = displacedView.bounds
        animatedImageView.frame.origin = origin
        animatedImageView.image = screenshot

        // Special case for where displaced view is an UIImageView
        if let displacedImageView = displacedView as? UIImageView {
            animatedImageView.contentMode = displacedImageView.contentMode
        }
        
        /// Put it into the container
        transitionContainerView.addSubview(animatedImageView)

        UIView.animateWithDuration(self.duration, animations: { () -> Void in

            if isPortraitOnly() == true {
                animatedImageView.transform = rotationTransform()
            }

            /// Animate it into the center (with optionaly rotating) - that basically includes changing the size and position
            let boundingSize = rotationAdjustedBounds().size
            let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: animatedImageView.bounds.size)

            animatedImageView.bounds.size = aspectFitSize
            animatedImageView.center = transitionContainerView.boundsCenter

            /// Transition the background to full black
            toViewController.view.alpha = 1.0

            }, completion: { [weak self] finished in

                animatedImageView.removeFromSuperview()
                transitionContext.completeTransition(finished)
                self?.displacedView.hidden = false

                onComplete?()

                /// Unhide gallery views
                if self?.decorationViewsHidden == false {

                    UIView.animateWithDuration(0.2, animations: { [weak self] in
                        self?.headerView?.alpha = 1.0
                        self?.footerView?.alpha = 1.0
                        self?.closeView?.alpha = 1.0
                        self?.seeAllView?.alpha = 1.0
                        })
                }
            })
    }

    func animationEnded(transitionCompleted: Bool) {

        /// The expected closure here should handle unhiding whichever ImageController is selected as the first one to be shown in gallery
        if transitionCompleted {
            completion?()
        }
    }
}