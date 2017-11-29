//
//  GalleryDisplacedViewsDataSource.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public protocol DisplaceableView {

    var image: UIImage? { get }
    var bounds: CGRect { get }
    var center: CGPoint { get }
    var boundsCenter: CGPoint { get }
    var contentMode: UIViewContentMode { get }
    var isHidden: Bool { get set }

    func convert(_ point: CGPoint, to view: UIView?) -> CGPoint
}

public protocol GalleryDisplacedViewsDataSource: class {

    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView?
}
