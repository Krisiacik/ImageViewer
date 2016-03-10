//
//  GalleryCollectionViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 10/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryCollectionViewController: UIViewController {
    
    //DATA
    private let viewModel: GalleryViewModel
    private let collectionView: UICollectionView
    
    init(viewModel: GalleryViewModel) {
        
        self.viewModel = viewModel
        self.collectionView = setupCollectionView(UIScreen.mainScreen().bounds)
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private func setupCollectionView(frame: CGRect) -> UICollectionView {
    
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 0
    
    let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
    collectionView.pagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    
    return collectionView
}