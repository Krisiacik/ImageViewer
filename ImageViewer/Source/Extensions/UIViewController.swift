//
//  UIViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 18/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    public func presentImageViewer(imageViewer: ImageViewerController, completion: ((Void) -> Void)? = {}) {
        
        present(imageViewer, animated: true, completion: completion)
    }
    
    public func presentImageGallery(gallery: GalleryViewController, completion: ((Void) -> Void)? = {}) {
        
        present(gallery, animated: true, completion: completion)
    }
}
