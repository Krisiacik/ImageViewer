//
//  UIView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension UIView {
    
    var boundsCenter: CGPoint {
        
        return CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
    }

    func frame(inCoordinatesOfView parentView: UIView) -> CGRect {

        let frameInWindow = UIApplication.applicationWindow.convertRect(self.bounds, fromView: self)
        return parentView.convertRect(frameInWindow, fromView: UIApplication.applicationWindow)
    }

    func addSubviews(subviews: UIView...) {

        for view in subviews { self.addSubview(view) }
    }
}