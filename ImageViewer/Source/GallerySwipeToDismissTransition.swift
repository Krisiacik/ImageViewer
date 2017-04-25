//
//  GallerySwipeToDismissTransition.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 03/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

enum SwipeToDismiss {

    case horizontal
    case vertical
}

final class GallerySwipeToDismissTransition {

    fileprivate weak var scrollView : UIScrollView?

    init(scrollView: UIScrollView?) {

        self.scrollView = scrollView
    }

    func updateInteractiveTransition(horizontalOffset hOffset: CGFloat = 0, verticalOffset vOffset: CGFloat = 0) {

        scrollView?.setContentOffset(CGPoint(x:  hOffset, y: vOffset), animated: false)
    }

    func finishInteractiveTransition(_ swipeDirection: SwipeToDismiss, touchPoint: CGFloat,  targetOffset: CGFloat, escapeVelocity: CGFloat, completion: (() -> Void)?) {

        /// In units of "vertical velocity". For example if we have a vertical velocity of 50 units (which are points really) per second
        /// and the distance to travel is 175 units, then our spring velocity is 3.5. I.e. we will travel 3.5 units in 1 second.
        let springVelocity = fabs(escapeVelocity / (targetOffset - touchPoint))

        /// How much time it will take to travel the remaining distance given the above speed.
        let expectedDuration = TimeInterval( fabs(targetOffset - touchPoint) / fabs(escapeVelocity))

        UIView.animate(withDuration: expectedDuration * 0.65, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: UIViewAnimationOptions.curveLinear, animations: { [weak self] () -> Void in

            switch swipeDirection {

            case .horizontal:   self?.scrollView?.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
            case .vertical:     self?.scrollView?.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: false)

            }
        }, completion: { (finished) -> Void in
                completion?()
        })
    }

    func cancelTransition(_ completion: (() -> Void)? = {}) {

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: { [weak self] () -> Void in

            self?.scrollView?.setContentOffset(CGPoint.zero, animated: false)

            }) { finished in

                completion?()
        }
    }
}
