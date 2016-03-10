//
//  GalleryCollectionViewCell.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 10/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    private let viewModel: GalleryViewModel
    private var imageController: ImageViewController
    
    var index : Int = 0 {
        didSet {
            
            updateImage(index)
        }
    }
    
    init(viewModel: GalleryViewModel, imageControllerDelegate: ImageViewControllerDelegate) {
        
        self.viewModel = viewModel
        self.imageController = ImageViewController(imageViewModel: viewModel, configuration: [], imageIndex: 0, showDisplacedImage: true, fadeInHandler: viewModel.fadeInHandler, delegate: imageControllerDelegate)

        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateImage(index: Int) {
        
        self.viewModel.fetchImage(index) { [weak self] image in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let fullSizedImage = image {
                    self?.updateImageAndContentSize(fullSizedImage)
                }
            }
        }
    }
    
    func updateImageAndContentSize(image: UIImage)  {
        
        scrollView.zoomScale = 1
        let aspectFitSize = aspectFitContentSize(forBoundingSize: rotationAdjustedBounds().size, contentSize: image.size)
        imageView.frame.size = aspectFitSize
        self.scrollView.contentSize = aspectFitSize
        imageView.center = scrollView.boundsCenter
    }
}
