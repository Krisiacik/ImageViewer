//
//  ImageViewControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

protocol ImageViewControllerDelegate: class {
    
    func imageViewController(controller: ImageViewController, swipeToDismissDistanceToEdge distance: CGFloat)
}
