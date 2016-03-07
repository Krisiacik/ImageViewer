//
//  ImageViewControllerFactory.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 06/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class ImageViewControllerFactory {
    
    var imageViewModel: GalleryViewModel
    var configuration: [GalleryConfiguration]
    var fadeInHandler: ImageFadeInHandler
    weak var delegate: ImageViewControllerDelegate?
    
    init(imageViewModel: GalleryViewModel, configuration: [GalleryConfiguration], fadeInHandler: ImageFadeInHandler, delegate: ImageViewControllerDelegate) {
        
        self.imageViewModel = imageViewModel
        self.configuration = configuration
        self.fadeInHandler = fadeInHandler
        self.delegate = delegate
    }
    
    func createImageViewController(imageIndex: Int) -> ImageViewController? {
      
        return ImageViewController(imageViewModel: imageViewModel, configuration: configuration, imageIndex: imageIndex, showDisplacedImage: (imageIndex == self.imageViewModel.startIndex), fadeInHandler: fadeInHandler, delegate: delegate)
    }
}


