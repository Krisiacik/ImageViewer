//
//  GalleryItem.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public typealias ConsumeImage = UIImage? -> Void
public typealias FetchImage = ConsumeImage -> Void

public enum GalleryItem {
    
    case Image(FetchImage)
    case Video(NSURL)
}