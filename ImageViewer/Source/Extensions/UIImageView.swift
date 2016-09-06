//
//  UIImageView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 19/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

extension DisplaceableView {

    func imageView() -> UIImageView {

        let imageView = UIImageView(image: self.image)
        imageView.bounds = self.bounds
        imageView.center = self.center
        imageView.contentMode = self.contentMode

        return imageView
    }
}