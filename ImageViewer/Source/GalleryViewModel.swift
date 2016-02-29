//
//  GalleryViewModel.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

protocol GalleryViewModel {
    
    var imageViewModels: GalleryImageViewModel { get }
    var headerView: UIView? { get }
    var footerView: UIView? { get }
    var reloadView: UIView  { get }
}