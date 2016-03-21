//
//  ImageFadeInHandler.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 02/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import Foundation

final class ImageFadeInHandler {
    
    var presentedImages:[Int] = []
    
    func imagePresentedAtIndex(index: Int) {
        
       presentedImages.append(index)
    }
    
    func wasPresented(index: Int) -> Bool {
        
        return presentedImages.contains(index)
    }
}