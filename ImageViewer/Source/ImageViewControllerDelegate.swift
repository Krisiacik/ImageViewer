//
//  ImageViewControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

protocol ImageViewControllerDelegate: class {
    
    func imageViewController(_ controller: ImageViewController, didSwipeToDismissWithDistanceToEdge distance: CGFloat)
    
    func imageViewControllerDidSingleTap(_ controller: ImageViewController)
    
    func imageViewControllerDidAppear(_ controller: ImageViewController)
}
