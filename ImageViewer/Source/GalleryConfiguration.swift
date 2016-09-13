//
//  GalleryConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public enum GalleryPagingMode {

    case standard
    case carousel
}

public typealias GalleryConfiguration = [GalleryConfigurationItem]

public enum GalleryConfigurationItem {

    case imageDividerWidth(CGFloat)
    case spinnerStyle(UIActivityIndicatorViewStyle)
    case spinnerColor(UIColor)
    case closeButton(UIButton)
    case seeAllButton(UIButton)
    case pagingMode(GalleryPagingMode)
    case closeLayout(ButtonLayout)
    case seeAllLayout(ButtonLayout)
    case headerViewLayout(HeaderLayout)
    case footerViewLayout(FooterLayout)
    case statusBarHidden(Bool)
    case hideDecorationViewsOnLaunch(Bool)
    case backgroundColor(UIColor)
}

func defaultGalleryConfiguration() -> GalleryConfiguration {

    let dividerWidth = GalleryConfigurationItem.imageDividerWidth(10)
    let spinnerColor = GalleryConfigurationItem.spinnerColor(UIColor.white)
    let spinnerStyle = GalleryConfigurationItem.spinnerStyle(UIActivityIndicatorViewStyle.white)

    let closeButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    closeButton.setImage(UIImage(named: "close_normal"), for: UIControlState.normal)
    closeButton.setImage(UIImage(named: "close_highlighted"), for: UIControlState.highlighted)
    let closeButtonConfig = GalleryConfigurationItem.closeButton(closeButton)

    let seeAllButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 50)))
    seeAllButton.setTitle("See All", for: .normal)
    let seeAllButtonConfig = GalleryConfigurationItem.seeAllButton(seeAllButton)

    let pagingMode = GalleryConfigurationItem.pagingMode(GalleryPagingMode.standard)

    let closeLayout = GalleryConfigurationItem.closeLayout(ButtonLayout.pinRight(12, 8))
    let seeAllLayout = GalleryConfigurationItem.seeAllLayout(ButtonLayout.pinLeft(12, 8))
    let headerLayout = GalleryConfigurationItem.headerViewLayout(HeaderLayout.center(25))
    let footerLayout = GalleryConfigurationItem.footerViewLayout(FooterLayout.center(25))

    let statusBarHidden = GalleryConfigurationItem.statusBarHidden(true)

    let hideDecorationViews = GalleryConfigurationItem.hideDecorationViewsOnLaunch(true)

    let backgroundColor = GalleryConfigurationItem.backgroundColor(.black)

    return [dividerWidth, spinnerStyle, spinnerColor, closeButtonConfig, seeAllButtonConfig, pagingMode, headerLayout, footerLayout, closeLayout, seeAllLayout, statusBarHidden, hideDecorationViews, backgroundColor]
}
