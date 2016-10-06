//
//  UIBezierPath.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 28/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension UIBezierPath {

    ///the orientation of this triangle is "pointing" to the right.
    static func equilateralTriangle(_ sideSize: CGFloat, shiftBy shift: CGPoint = CGPoint.zero) -> UIBezierPath {

        let path = UIBezierPath()

        ///The formula for calculating the altitude which is the shortest inner distance between the tip and the opposing edge in an equilateral triangle.
        let altitude = CGFloat(sqrt(3.0) / 2.0 * sideSize)
        path.move(to: CGPoint(x: 0 + shift.x, y: 0 + shift.y))
        path.addLine(to: CGPoint(x: 0 + shift.x, y: sideSize + shift.y))
        path.addLine(to: CGPoint(x: altitude + shift.x, y: (sideSize / 2) + shift.y))
        path.close()

        return path
    }
}
