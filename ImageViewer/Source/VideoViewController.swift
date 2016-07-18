//
//  VideoViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class VideoViewController: UIViewController, ItemController {

    let index: Int

    init(index: Int, video: NSURL, displacedViewsDatasource: GalleryDisplacedViewsDatasource?, configuration: GalleryConfiguration) {

        self.index = index
        super.init(nibName: nil, bundle: nil)
    }

    @available (iOS, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.2)

        let squareView = UIView(frame: CGRect(origin: CGPoint(x: 100, y: 100), size: CGSize(width: 20, height: 20)))
        squareView.backgroundColor = UIColor.greenColor()
        self.view.addSubview(squareView)
    }
}
