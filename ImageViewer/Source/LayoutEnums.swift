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

/// Represents possible layouts for the close button
public enum ButtonLayout {
    
    case PinLeft(MarginTop, MarginLeft)
    case PinRight(MarginTop, MarginRight)
}

/// Represents various possible layouts for the header
public enum HeaderLayout {
    
    case PinLeft(MarginTop, MarginLeft)
    case PinRight(MarginTop, MarginRight)
    case PinBoth(MarginTop, MarginLeft, MarginRight)
    case Center(MarginTop)
}

/// Represents various possible layouts for the footer
public enum FooterLayout {
    
    case PinLeft(MarginBottom, MarginLeft)
    case PinRight(MarginBottom, MarginRight)
    case PinBoth(MarginBottom, MarginLeft, MarginRight)
    case Center(MarginBottom)
}