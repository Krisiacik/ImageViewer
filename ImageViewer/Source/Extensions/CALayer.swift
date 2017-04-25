//
//  CALayer.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension CALayer {

    func toImage() -> UIImage {

        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        self.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
