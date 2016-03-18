//
//  ImageProvider.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 18/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public protocol ImageProvider {
    
    func provideImage(completion: UIImage? -> Void)
    func provideImage(atIndex index: Int, completion: UIImage? -> Void)
}