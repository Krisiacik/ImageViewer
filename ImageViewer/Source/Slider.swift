//
//  Slider.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 08/08/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class Slider: UISlider {

    dynamic var isSliding: Bool = false

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)

        isSliding = true
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)

        isSliding = false
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)

        isSliding = false
    }
}
