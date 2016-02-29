//
//  GalleryViewControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import Foundation

protocol GalleryViewControllerDelegate {
    
    func galleryViewController(controller: GalleryViewController, didSelectImageAtIndex: Int)
}