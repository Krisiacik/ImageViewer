//
//  ImageViewControllerFactory.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 06/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class ImageViewControllerFactory {

    private let imageProvider: ImageProvider
    private let displacedView: UIView
    private let imageCount: Int
    private let startIndex: Int
    private var configuration: GalleryConfiguration
    private var fadeInHandler: ImageFadeInHandler
    private weak var delegate: ImageViewControllerDelegate?

    init(imageProvider: ImageProvider, displacedView: UIView, imageCount: Int, startIndex: Int, configuration: GalleryConfiguration, fadeInHandler: ImageFadeInHandler, delegate: ImageViewControllerDelegate) {

        self.imageProvider = imageProvider
        self.displacedView = displacedView
        self.imageCount = imageCount
        self.startIndex = startIndex
        self.configuration = configuration
        self.fadeInHandler = fadeInHandler
        self.delegate = delegate
    }

    func createImageViewController(imageIndex: Int) -> ImageViewController {

        return ImageViewController(imageProvider: imageProvider,  configuration: configuration, imageCount: imageCount, displacedView: displacedView, startIndex: startIndex, imageIndex: imageIndex, showDisplacedImage: (imageIndex == self.startIndex), fadeInHandler: fadeInHandler, delegate: delegate)
    }
}
