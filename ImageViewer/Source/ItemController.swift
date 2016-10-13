//
//  ItemViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

typealias Duration = TimeInterval

@objc protocol ItemController: class {

    var index: Int { get }
    var isInitialController: Bool { get set }

    func presentItem(alongsideAnimation: () -> Void, completion: @escaping () -> Void)
    func dismissItem(alongsideAnimation: () -> Void, completion: @escaping () -> Void)

    @objc optional func closeDecorationViews(_ duration: TimeInterval)
}
