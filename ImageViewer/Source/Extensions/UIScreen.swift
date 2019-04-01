//
//  UIScreen.swift
//  ImageViewer
//
//  Created by David Whetstone on 11/21/17.
//  Copyright © 2017 MailOnline. All rights reserved.
//

import UIKit

public extension UIScreen {
    class var hasNotch: Bool {
        // This will of course fail if Apple produces an notchless iPhone with these dimensions,
        // but is the simplest detection mechanism so far.
        return main.nativeBounds.size == CGSize(width: 1125, height: 2436)
    }
}
