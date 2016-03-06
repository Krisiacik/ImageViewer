//
//  GalleryConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

enum GalleryPagingMode {
    
    case Standard
    case Carousel
}

enum GalleryConfiguration {
    
    case ImageDividerWidth(CGFloat)
    case SpinnerStyle(UIActivityIndicatorViewStyle)
    case SpinnerColor(UIColor)
    case CloseButton(UIButton)
    case PagingMode(GalleryPagingMode)
}

func defaultGalleryConfiguration() -> [GalleryConfiguration] {
    
    let dividerWidth = GalleryConfiguration.ImageDividerWidth(10)
    let spinnerColor = GalleryConfiguration.SpinnerColor(UIColor.whiteColor())
    let spinnerStyle = GalleryConfiguration.SpinnerStyle(UIActivityIndicatorViewStyle.White)
    
    let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    button.setImage(UIImage(named: "close_normal"), forState: UIControlState.Normal)
    button.setImage(UIImage(named: "close_highlighted"), forState: UIControlState.Highlighted)
    let closeButton = GalleryConfiguration.CloseButton(button)
    
    let pagingMode = GalleryConfiguration.PagingMode(GalleryPagingMode.Carousel)
    
    return [dividerWidth, spinnerStyle, spinnerColor, closeButton, pagingMode]
}