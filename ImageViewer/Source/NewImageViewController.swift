//
//  NewImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class NewImageViewController: UIViewController, ItemController {

    let index: Int
    var delegate: ItemControllerDelegate?

    init(index: Int, image: UIImage, displacedViewsDatasource: GalleryDisplacedViewsDatasource?,  configuration: GalleryConfiguration) {

        self.index = index
        super.init(nibName: nil, bundle: nil)
    }

    @available (iOS, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        let scrubber = UISlider(frame: CGRect(origin: CGPoint(x: 20, y: 100), size: CGSize(width: 200, height: 40)))

        scrubber.minimumValue = 0
        scrubber.maximumValue = 1000

        scrubber.addTarget(self, action: #selector(scrubberValueChanged), forControlEvents: UIControlEvents.ValueChanged)

        self.view.addSubview(scrubber)
    }

    func scrubberValueChanged(scrubber: UISlider) {

        self.delegate?.itemController(self, didTransitionWithProgress: CGFloat( 1 - scrubber.value / 1000))
    }
}
