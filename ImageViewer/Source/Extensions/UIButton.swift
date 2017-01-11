//
//  UIButton.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 28/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension UIButton {

    static func circlePlayButton(_ diameter: CGFloat) -> UIButton {

        let button = UIButton(type: .custom)
        button.frame = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))

        let circleImageNormal = CAShapeLayer.circlePlayShape(UIColor.white, diameter: diameter).toImage()
        button.setImage(circleImageNormal, for: .normal)

        let circleImageHighlighted = CAShapeLayer.circlePlayShape(UIColor.lightGray, diameter: diameter).toImage()
        button.setImage(circleImageHighlighted, for: .highlighted)

        return button
    }

    static func replayButton(width: CGFloat, height: CGFloat) -> UIButton {

        let smallerEdge = min(width, height)
        let triangleEdgeLength: CGFloat = min(smallerEdge, 20)

        let button = UIButton(type: .custom)
        button.bounds.size = CGSize(width: width, height: height)
        button.contentHorizontalAlignment = .center

        let playShapeNormal = CAShapeLayer.playShape(UIColor.red, triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeNormal, for: .normal)

        let playShapeHighlighted = CAShapeLayer.playShape(UIColor.red.withAlphaComponent(0.7), triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeHighlighted, for: .highlighted)

        ///the geometric center of equilateral triangle is not the same as the geometric center of its smallest bounding rect. There is some offset between the two centers to the left when the triangle points to the right. We have to shift the triangle to the right by that offset.
        let altitude = (sqrt(3) / 2) * triangleEdgeLength
        let innerCircleDiameter = (sqrt(3) / 6) * triangleEdgeLength

        button.imageEdgeInsets.left = altitude / 2 - innerCircleDiameter

        return button
    }

    static func playButton(width: CGFloat, height: CGFloat) -> UIButton {

        let smallerEdge = min(width, height)
        let triangleEdgeLength: CGFloat = min(smallerEdge, 20)

        let button = UIButton(type: .custom)
        button.bounds.size = CGSize(width: width, height: height)
        button.contentHorizontalAlignment = .center

        let playShapeNormal = CAShapeLayer.playShape(UIColor.white, triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeNormal, for: .normal)

        let playShapeHighlighted = CAShapeLayer.playShape(UIColor.white.withAlphaComponent(0.7), triangleEdgeLength: triangleEdgeLength).toImage()
        button.setImage(playShapeHighlighted, for: .highlighted)

        ///the geometric center of equilateral triangle is not the same as the geometric center of its smallest bounding rect. There is some offset between the two centers to the left when the triangle points to the right. We have to shift the triangle to the right by that offset.
        let altitude = (sqrt(3) / 2) * triangleEdgeLength
        let innerCircleDiameter = (sqrt(3) / 6) * triangleEdgeLength

        button.imageEdgeInsets.left = altitude / 2 - innerCircleDiameter

        return button
    }

    static func pauseButton(width: CGFloat, height: CGFloat) -> UIButton {

        let button = UIButton(type: .custom)
        button.contentHorizontalAlignment = .center

        let elementHeight = min(20, height)
        let elementSize = CGSize(width: elementHeight * 0.3, height: elementHeight)
        let distance: CGFloat = elementHeight * 0.2

        let pauseImageNormal = CAShapeLayer.pauseShape(UIColor.white, elementSize: elementSize, elementDistance: distance).toImage()
        button.setImage(pauseImageNormal, for: .normal)

        let pauseImageHighlighted = CAShapeLayer.pauseShape(UIColor.white.withAlphaComponent(0.7), elementSize: elementSize, elementDistance: distance).toImage()
        button.setImage(pauseImageHighlighted, for: .highlighted)

        return button
    }

    static func closeButton() -> UIButton {

        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        button.setImage(CAShapeLayer.closeShape(edgeLength: 15).toImage(), for: .normal)

        return button
    }

    static func thumbnailsButton() -> UIButton {

        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 50)))
        button.setTitle("See All", for: .normal)
        //button.titleLabel?.textColor = UIColor.redColor()

        return button
    }

    static func deleteButton() -> UIButton {

        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 80, height: 50)))
        button.setTitle("Delete", for: .normal)

        return button
    }
}
