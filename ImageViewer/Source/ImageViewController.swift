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

    override init(index: Int, itemCount: Int, fetchImageBlock: @escaping FetchImageBlock, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        super.init(index: index, itemCount: itemCount, fetchImageBlock: fetchImageBlock, configuration: configuration, isInitialController: isInitialController)
    }
}
