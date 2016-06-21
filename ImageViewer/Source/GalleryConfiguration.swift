//
//  GalleryConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public enum GalleryCloseButtonMode {
    
    case None
    case BuiltIn
    case Custom(UIButton)
}

public enum GalleryPagingMode {
    
    case Standard
    case Carousel
}

public typealias GalleryConfiguration = [GalleryConfigurationItem]

public enum GalleryConfigurationItem {
    
    case ImageDividerWidth(CGFloat)
    case SpinnerStyle(UIActivityIndicatorViewStyle)
    case SpinnerColor(UIColor)
    case CloseButtonMode(GalleryCloseButtonMode)
    case PagingMode(GalleryPagingMode)
    case CloseLayout(CloseButtonLayout)
    case HeaderViewLayout(HeaderLayout)
    case FooterViewLayout(FooterLayout)
    case StatusBarHidden(Bool)
    case HideDecorationViewsOnLaunch(Bool)
}