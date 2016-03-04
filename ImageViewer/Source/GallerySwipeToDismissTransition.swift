//
//  GallerySwipeToDismissTransition.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 03/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GallerySwipeToDismissTransition {
    
    weak var presentingViewController: UIViewController?
    weak var scrollView : UIScrollView?
    
    init(presentingViewController: UIViewController?, scrollView: UIScrollView?) {
        
        self.scrollView = scrollView
    }
    
    func updateInteractiveTransition(offset: CGFloat) {
        
        scrollView?.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
    }
    
    func finishInteractiveTransition(verticalTouchPoint: CGFloat,  targetOffset: CGFloat, escapeVelocity: CGFloat, completion: (() -> Void)?) {
        
        //guard escape velocity
        
        
            
            // in units of "vertical velocity". for example if we have a vertical velocity of 50 units (which are points really) per second
            // and the distance to travel is 175 units, then our spring velocity is 3.5. I.e. we will travel 3.5 units in 1 second.
            let springVelocity = fabs(escapeVelocity / (targetOffset - verticalTouchPoint))
        
            //how much time it will take to travel the remaining distance given the above speed.
            let expectedDuration = NSTimeInterval( fabs(targetOffset - verticalTouchPoint) / fabs(escapeVelocity))
            
            UIView.animateWithDuration(expectedDuration * 0.65, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.scrollView?.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: false)
                
                }, completion: { (finished) -> Void in
                   completion?()
            })
        }

    func cancelTransition() {
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveLinear, animations: { () -> Void in
            
            self.scrollView?.setContentOffset(CGPointZero, animated: false)
            
            }) { finished in
        }
    }
    
    func dismissTransition() {
        
    }
}