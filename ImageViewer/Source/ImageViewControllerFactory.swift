//
//  ImageViewControllerFactory.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 06/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class ImageViewControllerFactory {

    fileprivate let imageProvider: ImageProvider
    fileprivate let displacedView: UIView
    fileprivate let imageCount: Int
    fileprivate let startIndex: Int
    fileprivate var configuration: GalleryConfiguration
    fileprivate var fadeInHandler: ImageFadeInHandler
    fileprivate weak var delegate: ImageViewControllerDelegate?

    init(imageProvider: ImageProvider, displacedView: UIView, imageCount: Int, startIndex: Int, configuration: GalleryConfiguration, fadeInHandler: ImageFadeInHandler, delegate: ImageViewControllerDelegate) {

        self.imageProvider = imageProvider
        self.displacedView = displacedView
        self.imageCount = imageCount
        self.startIndex = startIndex
        self.configuration = configuration
        self.fadeInHandler = fadeInHandler
        self.delegate = delegate
    }

    func createImageViewController(_ imageIndex: Int) -> ImageViewController {

        return ImageViewController(imageProvider: imageProvider,  configuration: configuration, imageCount: imageCount, displacedView: displacedView, startIndex: startIndex, imageIndex: imageIndex, showDisplacedImage: (imageIndex == self.startIndex), fadeInHandler: fadeInHandler, delegate: delegate)
    }
}
