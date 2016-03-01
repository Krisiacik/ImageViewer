//
//  UtilityFunctions.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVFoundation

//returns a size that aspect-fits into the bounding size. Example -> We have some view of certain size and the question is, what would have to be its size, so that it would fit it into some rect of some size ..given we wuold want to keep the content rects aspect ratio.
public func aspectFitContentSize(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGSize {
    
    return AVMakeRectWithAspectRatioInsideRect(contentSize, CGRect(origin: CGPointZero, size: boundingSize)).size
}

public func aspectFillZoomScale(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGFloat {
    
    let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: contentSize)
    return (boundingSize.width == aspectFitSize.width) ? (boundingSize.height / aspectFitSize.height): (boundingSize.width / aspectFitSize.width)
}

public func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {
    
    // When the zoom scale changes i.e. the image is zoomed in or out, the hypothetical center
    // of content view changes too. But the default Apple implementation is keeping the last center
    // value which doesn't make much sense. If the image ratio is not matching the screen
    // ratio, there will be some empty space horizontaly or verticaly. This needs to be calculated
    // so that we can get the correct new center value. When these are added, edges of contentView
    // are aligned in realtime and always aligned with corners of scrollview.
    
    let horizontalOffest = (boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5): 0.0
    let verticalOffset = (boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5): 0.0
    
    return CGPoint(x: contentSize.width * 0.5 + horizontalOffest,  y: contentSize.height * 0.5 + verticalOffset)
}

public func zoomRect(ForScrollView scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
    
    let width = scrollView.frame.size.width  / scale
    let height = scrollView.frame.size.height / scale
    let originX = center.x - (width / 2.0)
    let originY = center.y - (height / 2.0)
    
    return CGRect(x: originX, y: originY, width: width, height: height)
}
