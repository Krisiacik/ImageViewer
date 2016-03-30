//
//  ImageFadeInHandler.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 02/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import Foundation

final class ImageFadeInHandler {
    
    private var presentedImages: [Int] = []
    
    func addPresentedImageIndex(index: Int) {
        
       presentedImages.append(index)
    }
    
    func wasPresented(index: Int) -> Bool {
        
        return presentedImages.contains(index)
    }
}