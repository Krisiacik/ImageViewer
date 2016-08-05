//
//  UISlider.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension UISlider {

    static func createSlider(width: CGFloat, height: CGFloat, pointerDiameter: CGFloat, barHeight: CGFloat) -> UISlider {

        let slider = UISlider(frame: CGRect(x: 0, y: 0, width: width, height: height))

        slider.setThumbImage(CAShapeLayer.circle(UIColor.whiteColor(), diameter: pointerDiameter).toImage(), forState: UIControlState.Normal)

        let tileImageFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: barHeight))

        let minTrackImage = CALayer()
        minTrackImage.backgroundColor = UIColor.whiteColor().CGColor
        minTrackImage.frame = tileImageFrame

        let maxTrackImage = CALayer()
        maxTrackImage.backgroundColor = UIColor.darkGrayColor().CGColor
        maxTrackImage.frame = tileImageFrame

        slider.setMinimumTrackImage(minTrackImage.toImage(), forState: UIControlState.Normal)
        slider.setMaximumTrackImage(maxTrackImage.toImage(), forState: UIControlState.Normal)
        
        return slider
    }
}