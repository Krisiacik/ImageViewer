//
//  UIImage.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 28/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public extension CAShapeLayer {

    public static func playShape(fillColor: UIColor, triangleEdgeLength: CGFloat) -> CAShapeLayer {

        let triangle = CAShapeLayer()
        let altitude = (sqrt(3) / 2) * triangleEdgeLength
        triangle.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: altitude, height: triangleEdgeLength))
        triangle.path = UIBezierPath.equilateralTriangle(triangleEdgeLength).CGPath
        triangle.fillColor = fillColor.CGColor

        return triangle
    }

    public static func pauseShape(fillColor: UIColor, elementSize: CGSize, elementDistance: CGFloat) -> CAShapeLayer {

        let element = CALayer()
        element.bounds.size = elementSize
        element.frame.origin = CGPoint.zero

        let secondElement = CALayer()
        secondElement.bounds.size = elementSize
        secondElement.frame.origin = CGPoint(x: elementSize.width + elementDistance, y: 0)

        [element, secondElement].forEach { $0.backgroundColor = fillColor.CGColor }

        let container = CAShapeLayer()
        container.bounds.size = CGSize(width: 2 * elementSize.width + elementDistance, height: elementSize.height)
        container.frame.origin = CGPoint.zero

        container.addSublayer(element)
        container.addSublayer(secondElement)

        return container
    }

    public static func circle(fillColor: UIColor, diameter: CGFloat) -> CAShapeLayer {

        let circle = CAShapeLayer()
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter * 2, height: diameter * 2))
        circle.frame = frame
        circle.path = UIBezierPath(ovalInRect: frame).CGPath
        circle.fillColor = fillColor.CGColor

        return circle
    }

    public static func circlePlayShape(fillColor: UIColor, diameter: CGFloat) -> CAShapeLayer {

        let circle = CAShapeLayer()
        let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: diameter, height: diameter))
        circle.frame = frame
        let circlePath = UIBezierPath(ovalInRect: frame)
        let trainglePath = UIBezierPath.equilateralTriangle(diameter / 2, shiftBy: CGPoint(x: diameter / 3, y: diameter / 4))

        circlePath.appendPath(trainglePath)
        circle.path = circlePath.CGPath
        circle.fillColor = fillColor.CGColor
        
        return circle
    }
}
