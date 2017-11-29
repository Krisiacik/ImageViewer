//
//  ItemControllerDelegate.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 18/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import Foundation


import UIKit

public protocol ItemControllerDelegate: class {

    ///Represents a generic transitioning progress from 0 to 1 (or reversed) where 0 is no progress and 1 is fully finished transitioning. It's up to the implementing controller to make decisions about how this value is being calculated, based on the nature of transition.
    func itemController(_ controller: ItemController, didSwipeToDismissWithDistanceToEdge distance: CGFloat)

    func itemControllerDidFinishSwipeToDismissSuccessfully()

    func itemControllerDidSingleTap(_ controller: ItemController)
    func itemControllerDidLongPress(_ controller: ItemController, in item: ItemView)

    func itemControllerWillAppear(_ controller: ItemController)
    func itemControllerWillDisappear(_ controller: ItemController)
    func itemControllerDidAppear(_ controller: ItemController)
}
