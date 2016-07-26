//
//  GalleryDatasource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 18/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public protocol GalleryItemsDatasource {
    
    func numberOfItemsInGalery() -> Int
    func provideGalleryItem(index: Int) -> GalleryItem
   // func provideSuplementaryItemAtIndex<T>(index: Int) -> T?
}
