//
//  NewGalleryPagingDatasource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final class NewGalleryPagingDatasource: NSObject, UIPageViewControllerDataSource {

    private let itemsDatasource: GalleryItemsDatasource
    private var displacedViewsDatasource: GalleryDisplacedViewsDatasource?
    private let configuration: GalleryConfiguration
    private let itemCount: Int
    private var pagingMode = GalleryPagingMode.Standard

    init(itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource?, configuration: GalleryConfiguration) {

        self.itemsDatasource = itemsDatasource
        self.displacedViewsDatasource = displacedViewsDatasource
        self.configuration = configuration
        self.itemCount = itemsDatasource.numberOfItemsInGalery()

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

        guard let currentController = viewController as? ItemViewController else { return nil }
        let previousIndex = (currentController.index == 0) ? itemCount - 1 : currentController.index - 1

        switch pagingMode {

        case .Standard:
            return (currentController.index > 0) ? self.createItemController(previousIndex) : nil

        case .Carousel:
            return self.createItemController(previousIndex)
        }
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {

        guard let currentController = viewController as? ItemViewController  else { return nil }
        let nextIndex = (currentController.index == itemCount - 1) ? 0 : currentController.index + 1

        switch pagingMode {

        case .Standard:
            return (currentController.index < itemCount - 1) ? self.createItemController(nextIndex) : nil

        case .Carousel:
            return self.createItemController(nextIndex)
        }
    }

    func createItemController(itemIndex: Int) -> ItemViewController {

        return ItemViewController(index: itemIndex, itemsDatasource: itemsDatasource, displacedViewsDatasource: displacedViewsDatasource, configuration: configuration)
    }
}
