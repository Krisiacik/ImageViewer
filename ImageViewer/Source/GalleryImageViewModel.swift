//
//  GalleryImageViewModel.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

protocol GalleryImageViewModel {
    
    var url: NSURL { get }
    var size: CGSize { get }
    
    func fetchImage(completion: UIImage? -> Void)
}

