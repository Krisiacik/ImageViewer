//
//  GalleryCollectionViewFlowLayout.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 11/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        scrollDirection = .Horizontal
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        itemSize = UIScreen.mainScreen().bounds.size
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
