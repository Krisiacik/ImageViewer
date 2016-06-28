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

public protocol GalleryDatasource {
    
    func numberOfItemsInGalery() -> Int
    func startingIndex() -> Int
    func provideDisplacementItem(atIndex index: Int, completion: UIImageView? -> Void)
    func provideGalleryItem(atIndex index: Int, completion: GalleryItem -> Void)
}