//
//  LivePhotoView.swift
//  ImageViewer
//
//  Created by Marcel Dittmann on 24.01.19.
//  Copyright © 2019 MailOnline. All rights reserved.
//

import UIKit
import PhotosUI

@available(iOS 9.1, *)
extension LivePhotoView: ItemView {}

@available(iOS 9.1, *)
class LivePhotoView: UIView {
    
    var phLivePhotoView = PHLivePhotoView()
    var image: UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(phLivePhotoView)
        
        phLivePhotoView.contentMode = .scaleAspectFill
        phLivePhotoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        phLivePhotoView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
