//
//  ItemViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

typealias Duration = NSTimeInterval

@objc protocol ItemController: class {

    var index: Int { get }
    var isInitialController: Bool { get set }

    func presentItem(alongsideAnimation alongsideAnimation: () -> Void, completion: () -> Void)
    func dismissItem(alongsideAnimation alongsideAnimation: () -> Void, completion: () -> Void)

    optional func closeDecorationViews(duration: NSTimeInterval)
}