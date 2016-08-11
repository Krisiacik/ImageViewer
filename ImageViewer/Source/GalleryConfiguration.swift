//
//  GalleryConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public enum GalleryPagingMode {

    case Standard
    case Carousel
}

public typealias GalleryConfiguration = [GalleryConfigurationItem]

public enum GalleryConfigurationItem {

    case ImageDividerWidth(CGFloat)
    case SpinnerStyle(UIActivityIndicatorViewStyle)
    case SpinnerColor(UIColor)
    case CloseButton(UIButton)
    case SeeAllButton(UIButton)
    case PagingMode(GalleryPagingMode)
    case CloseLayout(ButtonLayout)
    case SeeAllLayout(ButtonLayout)
    case HeaderViewLayout(HeaderLayout)
    case FooterViewLayout(FooterLayout)
    case StatusBarHidden(Bool)
    case HideDecorationViewsOnLaunch(Bool)
    case BackgroundColor(UIColor)
}

func defaultGalleryConfiguration() -> GalleryConfiguration {

    let dividerWidth = GalleryConfigurationItem.ImageDividerWidth(10)
    let spinnerColor = GalleryConfigurationItem.SpinnerColor(UIColor.whiteColor())
    let spinnerStyle = GalleryConfigurationItem.SpinnerStyle(UIActivityIndicatorViewStyle.White)

    let closeButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    closeButton.setImage(UIImage(named: "close_normal"), forState: UIControlState.Normal)
    closeButton.setImage(UIImage(named: "close_highlighted"), forState: UIControlState.Highlighted)
    let closeButtonConfig = GalleryConfigurationItem.CloseButton(closeButton)

    let seeAllButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 50)))
    seeAllButton.setTitle("See All", forState: .Normal)
    let seeAllButtonConfig = GalleryConfigurationItem.SeeAllButton(seeAllButton)

    let pagingMode = GalleryConfigurationItem.PagingMode(GalleryPagingMode.Standard)

    let closeLayout = GalleryConfigurationItem.CloseLayout(ButtonLayout.PinRight(8, 16))
    let seeAllLayout = GalleryConfigurationItem.CloseLayout(ButtonLayout.PinLeft(8, 16))
    let headerLayout = GalleryConfigurationItem.HeaderViewLayout(HeaderLayout.Center(25))
    let footerLayout = GalleryConfigurationItem.FooterViewLayout(FooterLayout.Center(25))

    let statusBarHidden = GalleryConfigurationItem.StatusBarHidden(true)

    let hideDecorationViews = GalleryConfigurationItem.HideDecorationViewsOnLaunch(true)

    let backgroundColor = GalleryConfigurationItem.BackgroundColor(.blackColor())

    return [dividerWidth, spinnerStyle, spinnerColor, closeButtonConfig, seeAllButtonConfig, pagingMode, headerLayout, footerLayout, closeLayout, seeAllLayout, statusBarHidden, hideDecorationViews, backgroundColor]
}
