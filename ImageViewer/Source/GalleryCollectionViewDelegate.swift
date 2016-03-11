//
//  GalleryCollectionViewDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 11/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryCollectionViewDelegate: NSObject, UICollectionViewDelegate {

    var updatedSize = UIScreen.mainScreen().bounds.size
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return updatedSize
    }
    /*
    
    - (CGSize)collectionView:(UICollectionView *)collectionView
    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath
    {
    // Adjust cell size for orientation
    if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
    return CGSizeMake(170.f, 170.f);
    }
    return CGSizeMake(192.f, 192.f);
    }
    
    - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
    {
    [self.collectionView performBatchUpdates:nil completion:nil];
    }
    
    */
}
