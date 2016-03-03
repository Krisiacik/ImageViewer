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
    
    func finishInteractiveTransition(escapeVelocity: CGFloat) {
        
    }
    
    func cancelTransition() {
        
    }
    
    
    func dismissTransition() {
        
    }
}