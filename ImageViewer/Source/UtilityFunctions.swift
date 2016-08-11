//
//  UtilityFunctions.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVFoundation

/// returns a size that aspect-fits into the bounding size. Example -> We have some view of 
/// certain size and the question is, what would have to be its size, so that it would fit 
/// it into some rect of some size ..given we wuold want to keep the content rects aspect ratio.
func aspectFitContentSize(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGSize {
    
    return AVMakeRectWithAspectRatioInsideRect(contentSize, CGRect(origin: CGPointZero, size: boundingSize)).size
}

func aspectFillZoomScale(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGFloat {
    
    let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: contentSize)
    return (boundingSize.width == aspectFitSize.width) ? (boundingSize.height / aspectFitSize.height): (boundingSize.width / aspectFitSize.width)
}

func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {
    
    /// When the zoom scale changes i.e. the image is zoomed in or out, the hypothetical center
    /// of content view changes too. But the default Apple implementation is keeping the last center
    /// value which doesn't make much sense. If the image ratio is not matching the screen
    /// ratio, there will be some empty space horizontaly or verticaly. This needs to be calculated
    /// so that we can get the correct new center value. When these are added, edges of contentView
    /// are aligned in realtime and always aligned with corners of scrollview.
    
    let horizontalOffest = (boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5): 0.0
    let verticalOffset = (boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5): 0.0
    
    return CGPoint(x: contentSize.width * 0.5 + horizontalOffest,  y: contentSize.height * 0.5 + verticalOffset)
}

func zoomRect(ForScrollView scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
    
    let width = scrollView.frame.size.width  / scale
    let height = scrollView.frame.size.height / scale
    let originX = center.x - (width / 2.0)
    let originY = center.y - (height / 2.0)
    
    return CGRect(x: originX, y: originY, width: width, height: height)
}

func screenshotFromView(view: UIView) -> UIImage {
    
    // Special case for where displaced view is an UIImageView
    if let imageView = view as? UIImageView, image = imageView.image {
        return image
    }

    let image: UIImage
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.mainScreen().scale)
    view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
    image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
}

func rotationTransform() -> CGAffineTransform {
    
    return CGAffineTransformMakeRotation(degreesToRadians(rotationAngleToMatchDeviceOrientation(UIDevice.currentDevice().orientation)))
}

func degreesToRadians(degree: CGFloat) -> CGFloat {
    return CGFloat(M_PI) * degree / 180
}

private func rotationAngleToMatchDeviceOrientation(orientation: UIDeviceOrientation) -> CGFloat {
    
    var desiredRotationAngle: CGFloat = 0
    
    switch orientation {
    case .LandscapeLeft:                    desiredRotationAngle = 90
    case .LandscapeRight:                   desiredRotationAngle = -90
    case .PortraitUpsideDown:               desiredRotationAngle = 180
    default:                                desiredRotationAngle = 0
    }
    
    return desiredRotationAngle
}

func rotationAdjustedBounds() -> CGRect {
    
    let applicationWindow = UIApplication.sharedApplication().delegate?.window?.flatMap { $0 }
    guard let window = applicationWindow else { return UIScreen.mainScreen().bounds }
    
    if isPortraitOnly() {
        
        return (UIDevice.currentDevice().orientation.isLandscape) ? CGRect(origin: CGPointZero, size: window.bounds.size.inverted()): window.bounds
    }
    
    return window.bounds
}

func isPortraitOnly() -> Bool {
    
    return UIApplication.sharedApplication().supportedInterfaceOrientationsForWindow(nil) == .Portrait
}

func maximumZoomScale(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGFloat {
    
    /// we want to allow the image to always cover 4x the area of screen
    return min(boundingSize.width, boundingSize.height) / min(contentSize.width, contentSize.height) * 4
}

func rotationAdjustedCenter(view: UIView) -> CGPoint {
    
    guard isPortraitOnly() else { return view.center }
    
    return (UIDevice.currentDevice().orientation.isLandscape) ? view.center.inverted() : view.center
}

func layoutAspectFit(view: UIView, image: UIImage) {
    let widthRatio = image.size.width / view.bounds.size.width
    let heightRatio = image.size.height / view.bounds.size.height

    let newWidth = image.size.width / max(widthRatio, heightRatio)
    let newHeight = image.size.height / max(widthRatio, heightRatio)

    let origin = CGPoint(
        x: view.frame.origin.x + ((view.frame.width - newWidth) / 2),
        y: view.frame.origin.y + ((view.frame.height - newHeight) / 2))
    let size = CGSize(width: newWidth, height: newHeight)

    view.frame = CGRect(origin: origin, size: size)
}
