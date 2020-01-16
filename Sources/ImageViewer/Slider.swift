//
//  Slider.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 08/08/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class Slider: UISlider {

    @objc dynamic var isSliding: Bool = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        isSliding = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        isSliding = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        isSliding = false
    }
}
