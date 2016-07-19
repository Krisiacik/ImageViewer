//
//  CGRect.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 19/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension UIView {

    func frame(inCoordinatesOfView parentView: UIView) -> CGRect {

        let frameInWindow = UIApplication.applicationWindow.convertRect(self.bounds, fromView: self)
        return parentView.convertRect(frameInWindow, fromView: UIApplication.applicationWindow)
    }
}
