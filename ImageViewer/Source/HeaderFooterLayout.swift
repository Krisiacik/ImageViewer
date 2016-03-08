//
//  HeaderFooterLayout.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 08/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public typealias MarginLeft = CGFloat
public typealias MarginRight = CGFloat
public typealias MarginTop = CGFloat
public typealias MarginBottom = CGFloat

public enum HeaderLayout {
    
    case PinLeft(MarginTop, MarginLeft)
    case PinRight(MarginTop, MarginRight)
    case PinBoth(MarginTop, MarginLeft, MarginRight)
    case Center(MarginTop)
}

public enum FooterLayout {
    
    case PinLeft(MarginBottom, MarginLeft)
    case PinRight(MarginBottom, MarginRight)
    case PinBoth(MarginBottom, MarginLeft, MarginRight)
    case Center(MarginBottom)
}
