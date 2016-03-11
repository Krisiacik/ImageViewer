//
//  GalleryCollectionViewCell.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 10/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    private var viewModel: GalleryViewModel?
    private var imageControllerDelegate: ImageViewControllerDelegate?
    private var imageController: ImageViewController?
    var index : Int = 0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        self.imageController = nil
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: GalleryViewModel, imageControllerDelegate: ImageViewControllerDelegate, index: Int) {
        
        self.viewModel = viewModel
        self.imageControllerDelegate = imageControllerDelegate
        
        let imageController = ImageViewController(imageViewModel: viewModel, configuration: [], imageIndex: index, showDisplacedImage: false, fadeInHandler: ImageFadeInHandler(), delegate: imageControllerDelegate)
        self.imageController = imageController

        imageController.view.translatesAutoresizingMaskIntoConstraints = false
        imageController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.addSubview(imageController.view)
    }
}
