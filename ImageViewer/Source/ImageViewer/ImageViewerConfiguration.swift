//
//  ImageViewerConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 18/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public struct CloseButtonAssets {
    
    public let normal: UIImage
    public let highlighted: UIImage?
    
    public init(normal: UIImage, highlighted: UIImage?) {
        
        self.normal = normal
        self.highlighted = highlighted
    }
}

public struct ImageViewerConfiguration {
    
    public let imageSize: CGSize
    public let closeButtonAssets: CloseButtonAssets
    public let backgroundColor: UIColor

    public init(imageSize: CGSize, closeButtonAssets: CloseButtonAssets, backgroundColor: UIColor = UIColor.blackColor()) {
        self.imageSize = imageSize
        self.closeButtonAssets = closeButtonAssets
        self.backgroundColor = backgroundColor
    }
}