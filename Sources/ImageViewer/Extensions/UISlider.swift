//
//  UISlider.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension Slider {

    static func createSlider(_ width: CGFloat, height: CGFloat, pointerDiameter: CGFloat, barHeight: CGFloat) -> Slider {

        let slider = Slider(frame: CGRect(x: 0, y: 0, width: width, height: height))

        slider.setThumbImage(CAShapeLayer.circle(UIColor.white, diameter: pointerDiameter).toImage(), for: UIControl.State())

        let tileImageFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: barHeight))

        let minTrackImage = CALayer()
        minTrackImage.backgroundColor = UIColor.white.cgColor
        minTrackImage.frame = tileImageFrame

        let maxTrackImage = CALayer()
        maxTrackImage.backgroundColor = UIColor.darkGray.cgColor
        maxTrackImage.frame = tileImageFrame

        slider.setMinimumTrackImage(minTrackImage.toImage(), for: UIControl.State())
        slider.setMaximumTrackImage(maxTrackImage.toImage(), for: UIControl.State())

        return slider
    }
    
    override func tintColorDidChange() {
        self.minimumTrackTintColor = self.tintColor
        self.maximumTrackTintColor = self.tintColor.shadeDarker()
        
        // Correct way would be setting self.thumbTintColor however this has a bug which changes the thumbImage frame
        let image = self.currentThumbImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.setThumbImage(image, for: UIControl.State.normal)
    }
}
