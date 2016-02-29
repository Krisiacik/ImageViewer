//
//  UtilityFunctions.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import Foundation
import AVFoundation

//returns a size that aspect-fits into the bounding size. Example -> We have some view of certain size and the question is, what would have to be its size, so that it would fit it into some rect of some size ..given we wuold want to keep the content rects aspect ratio.
public func aspectFitContentSize(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGSize {
    
    return AVMakeRectWithAspectRatioInsideRect(contentSize, CGRect(origin: CGPointZero, size: boundingSize)).size
}