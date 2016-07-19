//
//  GalleryDisplacedViewsDatasource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public protocol GalleryDisplacedViewsDatasource {
    
    func provideDisplacementItem(atIndex index: Int) -> UIView?
}