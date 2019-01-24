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
        
        phLivePhotoView.translatesAutoresizingMaskIntoConstraints = false

        let top = phLivePhotoView.topAnchor.constraint(equalTo: self.topAnchor)
        let bottom = phLivePhotoView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let leading = phLivePhotoView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let trailing = self.trailingAnchor.constraint(equalTo: phLivePhotoView.trailingAnchor, constant: 5)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
