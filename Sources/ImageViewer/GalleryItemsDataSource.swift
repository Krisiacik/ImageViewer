//
//  GalleryItemsDataSource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 18/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public protocol GalleryItemsDataSource: class {

    func itemCount() -> Int
    func provideGalleryItem(_ index: Int) -> GalleryItem
}
