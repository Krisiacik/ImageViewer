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

    case pinLeft(MarginTop, MarginLeft)
    case pinRight(MarginTop, MarginRight)
}

/// Represents various possible layouts for the header
public enum HeaderLayout {

    case pinLeft(MarginTop, MarginLeft)
    case pinRight(MarginTop, MarginRight)
    case pinBoth(MarginTop, MarginLeft, MarginRight)
    case center(MarginTop)
}

/// Represents various possible layouts for the footer
public enum FooterLayout {

    case pinLeft(MarginBottom, MarginLeft)
    case pinRight(MarginBottom, MarginRight)
    case pinBoth(MarginBottom, MarginLeft, MarginRight)
    case center(MarginBottom)
}
