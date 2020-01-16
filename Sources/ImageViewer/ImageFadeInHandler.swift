//
//  ImageFadeInHandler.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 02/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import Foundation

final class ImageFadeInHandler {

    fileprivate var presentedImages: [Int] = []

    func addPresentedImageIndex(_ index: Int) {

       presentedImages.append(index)
    }

    func wasPresented(_ index: Int) -> Bool {

        return presentedImages.contains(index)
    }
}
