//
//  UIButton.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 28/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public extension UIButton {

    public static func circlePlayButton(diameter: CGFloat) -> UIButton {

        let button = UIButton(type: UIButtonType.Custom)
        button.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter))

        let circleImageNormal = CAShapeLayer.circlePlayShape(UIColor.whiteColor(), diameter: diameter).toImage()
        button.setImage(circleImageNormal, forState: UIControlState.Normal)

        let circleImageHighlighted = CAShapeLayer.circlePlayShape(UIColor.lightGrayColor(), diameter: diameter).toImage()
        button.setImage(circleImageHighlighted, forState: UIControlState.Highlighted)
        return button
    }

    public static func playButton(width width: CGFloat, height: CGFloat) -> UIButton {

        let smallerEdge = min(width, height)
        let triangleEdgeLength: CGFloat = min(smallerEdge, 20)

        let button = UIButton(type: UIButtonType.Custom)
        button.bounds.size = CGSize(width: width, height: height)
        button.contentHorizontalAlignment = .Center

        let playShapeNormal = CAShapeLayer.playShape(UIColor.whiteColor(), triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeNormal, forState: UIControlState.Normal)

        let playShapeHighlighted = CAShapeLayer.playShape(UIColor.whiteColor().colorWithAlphaComponent(0.7), triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeHighlighted, forState: UIControlState.Highlighted)

        ///the geometric center of equilateral triangle is not the same as the geometric center of its smallest bounding rect. There is some offset between the two centers to the left when the triangle points to the right. We have to shift the triangle to the right by that offset.
        let altitude = (sqrt(3) / 2) * triangleEdgeLength
        let innerCircleDiameter = (sqrt(3) / 6) * triangleEdgeLength

        button.imageEdgeInsets.left = altitude / 2 - innerCircleDiameter

        return button
    }

    public  static func pauseButton(width width: CGFloat, height: CGFloat) -> UIButton {

        let button = UIButton(type: UIButtonType.Custom)
        button.contentHorizontalAlignment = .Center

        let elementHeight = min(20, height)
        let elementSize = CGSize(width: elementHeight * 0.3, height: elementHeight)
        let distance: CGFloat = elementHeight * 0.2

        let pauseImageNormal = CAShapeLayer.pauseShape(UIColor.whiteColor(), elementSize: elementSize, elementDistance: distance).toImage()
        button.setImage(pauseImageNormal, forState: UIControlState.Normal)

        let pauseImageHighlighted = CAShapeLayer.pauseShape(UIColor.whiteColor().colorWithAlphaComponent(0.7), elementSize: elementSize, elementDistance: distance).toImage()
        button.setImage(pauseImageHighlighted, forState: UIControlState.Highlighted)
        
        return button
    }
}