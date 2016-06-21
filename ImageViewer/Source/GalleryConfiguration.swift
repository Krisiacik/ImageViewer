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
    case BuiltIn /// Standard white X with transparent tappable area, positioned in the top right corner.
    case Custom(UIButton)
}

public enum GalleryPagingMode {
    
    case Standard /// Allows paging through images from 0 to N, when first or last image reached ,horizontal swipe to dismiss kicks in.
    case Carousel /// Pages through images from 0 to N and the again 0 to N in a loop, works both directions.
}

public typealias GalleryConfiguration = [GalleryConfigurationItem]

public enum GalleryConfigurationItem {
    
    case ImageDividerWidth(CGFloat) /// Distance (width of the area) between images when paged.
    case SpinnerStyle(UIActivityIndicatorViewStyle) /// This spinner is shown when we page to an image page, but the image itself is still loading.
    case SpinnerColor(UIColor) /// Color of the spinner above.
    case CloseButtonMode(GalleryCloseButtonMode)
    case PagingMode(GalleryPagingMode)
    case CloseLayout(CloseButtonLayout) /// Layout behaviour for the close button.
    case HeaderViewLayout(HeaderLayout) /// Layout behaviour for optional header view.
    case FooterViewLayout(FooterLayout) /// Layout behaviour for optional footer view.
    case StatusBarHidden(Bool) /// Sets the status bar visible/invisible while gallery is presented.
    case HideDecorationViewsOnLaunch(Bool) /// Sets the close button, header view and footer view visible/invisible on launch. Visibility of these three views is toggled by single tapping anywhere in the gallery area. This setting is global to Gallery. 
}