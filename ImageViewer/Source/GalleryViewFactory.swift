//
//  GalleryViewFactory.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 21/06/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

func makeCloseButton() -> UIButton {
    
    let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
    button.setImage(UIImage(named: "close_normal"), forState: UIControlState.Normal)
    button.setImage(UIImage(named: "close_highlighted"), forState: UIControlState.Highlighted)
    
    return button
}
