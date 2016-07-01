//
//  ItemViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class GalleryItemViewController: UIViewController {
    
    init(itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource?, configuration: GalleryConfiguration) {
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.backgroundColor = UIColor.redColor()
    }
}
