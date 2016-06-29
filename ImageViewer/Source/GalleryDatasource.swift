//
//  GalleryDatasource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 18/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public enum GalleryItem {
    
    case Image(UIImage)
    case Video(NSURL)
}

public protocol GalleryItemsDatasource {
    
    func numberOfItemsInGalery() -> Int
    func provideGalleryItem(atIndex index: Int, completion: GalleryItem -> Void)
}

public protocol GalleryDisplacedViewsDatasource {

    func provideDisplacementItem(atIndex index: Int, completion: UIView? -> Void)
}