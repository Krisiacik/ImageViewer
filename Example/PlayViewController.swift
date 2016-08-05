//
//  PlayViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 28/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class PlayViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        let scrubber = VideoScrubber(frame: CGRect(x: 20, y: 200, width: 300, height: 50))

        scrubber.backgroundColor = UIColor.redColor()

        self.view.addSubview(scrubber)
    }
}