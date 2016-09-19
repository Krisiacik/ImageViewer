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

    override init(index: Int, itemCount: Int, fetchImageBlock: FetchImageBlock, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        print("ImageViewController init 🏔")

        super.init(index: index, itemCount: itemCount, fetchImageBlock: fetchImageBlock, configuration: configuration, isInitialController: isInitialController)
    }

    deinit {

        print("ImageViewController deinit 🔫")
    }
}