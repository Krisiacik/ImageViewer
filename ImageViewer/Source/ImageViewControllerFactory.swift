//
//  ImageViewControllerFactory.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 06/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class ImageViewControllerFactory {
    
    private let itemsDatasource: GalleryItemsDatasource
    private var displacedViewsDatasource: GalleryDisplacedViewsDatasource?
    private let startIndex: Int
    private var configuration: GalleryConfiguration
    private var fadeInHandler: ImageFadeInHandler
    private weak var delegate: ImageViewControllerDelegate?
    
    init(itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource?, startIndex: Int, configuration: GalleryConfiguration, fadeInHandler: ImageFadeInHandler, delegate: ImageViewControllerDelegate) {
        
        self.itemsDatasource = itemsDatasource
        self.displacedViewsDatasource = displacedViewsDatasource
        self.startIndex = startIndex
        self.configuration = configuration
        self.fadeInHandler = fadeInHandler
        self.delegate = delegate
    }
    
    func createImageViewController(imageIndex: Int) -> ImageViewController? {
        
        return ImageViewController(itemsDatasource: itemsDatasource, displacedViewsDatasource: displacedViewsDatasource, configuration: configuration, startIndex: startIndex, imageIndex: imageIndex, fadeInHandler: fadeInHandler, delegate: delegate)
    }
}