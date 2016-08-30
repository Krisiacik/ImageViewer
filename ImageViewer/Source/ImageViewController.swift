//
//  ImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension UIImageView: ItemView {}

class ImageViewController: ItemBaseController<UIImageView> {

    var fetchImageBlock: FetchImage

    init(index: Int, itemCount: Int, fetchImageBlock: FetchImage, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.fetchImageBlock = fetchImageBlock

        super.init(index: index, itemCount: itemCount, configuration: configuration, isInitialController: isInitialController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchImageBlock { [weak self] image in //DON'T Forget offloading the main thread

            if let image = image {

                self?.itemView.image = image
            }
        }
    }
}