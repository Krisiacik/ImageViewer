//
//  ItemViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {

    let index: Int

    init(index: Int, itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource?, configuration: GalleryConfiguration) {

        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2)

        let smallView = UIView(frame: CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: 20, height: 20)))
        smallView.backgroundColor = UIColor.yellowColor()

        self.view.addSubview(smallView)
    }
}