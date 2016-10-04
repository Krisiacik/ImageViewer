//
//  GalleryPagingDatasource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class GalleryPagingDatasource: NSObject, UIPageViewControllerDataSource {

    weak var itemControllerDelegate: ItemControllerDelegate?
    private weak var itemsDatasource: GalleryItemsDatasource?
    private weak var displacedViewsDatasource: GalleryDisplacedViewsDatasource?

    private let configuration: GalleryConfiguration
    private var pagingMode = GalleryPagingMode.Standard
    private let itemCount: Int
    private unowned var scrubber: VideoScrubber

    init(itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource?, scrubber: VideoScrubber, configuration: GalleryConfiguration) {

        self.itemsDatasource = itemsDatasource
        self.displacedViewsDatasource = displacedViewsDatasource
        self.scrubber = scrubber
        self.configuration = configuration
        self.itemCount = itemsDatasource.itemCount()

        if itemCount > 1 { // Potential carousel mode present in configuration only makes sense for more than 1 item

            for item in configuration {

                switch item {

                case .PagingMode(let mode): pagingMode = mode
                default: break
                }
            }
        }
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        guard let currentController = viewController as? ItemController else { return nil }
        let previousIndex = (currentController.index == 0) ? itemCount - 1 : currentController.index - 1

        switch pagingMode {

        case .Standard:
            return (currentController.index > 0) ? self.createItemController(previousIndex) : nil

        case .Carousel:
            return self.createItemController(previousIndex)
        }
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        guard let currentController = viewController as? ItemController  else { return nil }
        let nextIndex = (currentController.index == itemCount - 1) ? 0 : currentController.index + 1

        switch pagingMode {

        case .Standard:
            return (currentController.index < itemCount - 1) ? self.createItemController(nextIndex) : nil

        case .Carousel:
            return self.createItemController(nextIndex)
        }
    }

    func createItemController(itemIndex: Int, isInitial: Bool = false) -> UIViewController {

        guard let itemsDatasource = itemsDatasource else { return UIViewController() }

        let item = itemsDatasource.provideGalleryItem(itemIndex)

        switch item {

        case .Image(let fetchImageBlock):

            let imageController = ImageViewController(index: itemIndex, itemCount: itemsDatasource.itemCount(), fetchImageBlock: fetchImageBlock, configuration: configuration, isInitialController: isInitial)
            imageController.delegate = itemControllerDelegate
            imageController.displacedViewsDatasource = displacedViewsDatasource

            return imageController

        case .Video(let fetchImageBlock, let videoURL):

            let videoController = VideoViewController(index: itemIndex, itemCount: itemsDatasource.itemCount(), fetchImageBlock: fetchImageBlock, videoURL: videoURL, scrubber: scrubber, configuration: configuration, isInitialController: isInitial)

            videoController.delegate = itemControllerDelegate
            videoController.displacedViewsDatasource = displacedViewsDatasource

            return videoController
        }
    }
}
