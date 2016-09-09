//
//  GalleryItem.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public typealias ImageCompletion = UIImage? -> Void
public typealias FetchImageBlock = ImageCompletion -> Void

public enum GalleryItem {
    
    case Image(fetchImageBlock: FetchImageBlock)
    case Video(fetchPreviewImageBlock: FetchImageBlock, videoURL: NSURL)
}
