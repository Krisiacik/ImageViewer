//
//  GalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryViewController: UIPageViewController {
    
    let viewModel: GalleryViewModel
    
    init(viewModel: GalleryViewModel) {
        
        self.viewModel = viewModel
        
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

