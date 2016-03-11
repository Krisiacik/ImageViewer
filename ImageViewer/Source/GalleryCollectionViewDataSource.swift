//
//  GalleryCollectionViewDataSource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 10/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit


class GalleryCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    let viewModel: GalleryViewModel
    let imageControllerDelegate: ImageViewControllerDelegate
    
    init(viewModel: GalleryViewModel, imageControllerDelegate: ImageViewControllerDelegate) {
        
        self.viewModel = viewModel
        self.imageControllerDelegate = imageControllerDelegate
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.imageCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! GalleryCollectionViewCell
       
        cell.configure(viewModel, imageControllerDelegate: imageControllerDelegate, index: indexPath.row)
        
        return cell
    }
}