//
//  OLDImageViewControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

protocol OLDImageViewControllerDelegate: class {
    
    func imageViewController(controller: OLDImageViewController, didSwipeToDismissWithDistanceToEdge distance: CGFloat)
    
    func imageViewControllerDidSingleTap(controller: OLDImageViewController)
    
    func imageViewControllerDidAppear(controller: OLDImageViewController)
}