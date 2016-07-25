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
    var isInitialController = false

    init(index: Int, video: NSURL, displacedViewsDatasource: GalleryDisplacedViewsDatasource?, configuration: GalleryConfiguration) {

        self.index = index
        super.init(nibName: nil, bundle: nil)
    }

    @available (iOS, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func presentItem(alongsideAnimation alongsideAnimation: Duration -> Void) {

    }

    func dismissItem(alongsideAnimation alongsideAnimation: () -> Void, completion: () -> Void) {

    }
}
