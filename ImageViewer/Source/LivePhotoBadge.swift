//
//  LivePhotoBadge.swift
//  ImageViewer
//
//  Created by Marcel Dittmann on 24.01.19.
//  Copyright © 2019 MailOnline. All rights reserved.
//

import UIKit
import PhotosUI

extension UIView {
    
    @available(iOS 9.1, *)
    public class func livePhotoBadge() -> UIView {
        
        let darkColor = UIColor.init(white: 0, alpha: 0.7)
        
        let icon = UIImageView(image: PHLivePhotoView.livePhotoBadgeImage(options: .overContent).withRenderingMode(.alwaysTemplate))
        icon.tintColor = darkColor
    
        let label = UILabel(frame: .zero)
        label.textColor = darkColor
        label.text = "LIVE"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        let badge = UIView()
        badge.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
        badge.clipsToBounds = true
        badge.layer.cornerRadius = 2
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: [icon, label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        badge.addSubview(stackView)
        
        let top = stackView.topAnchor.constraint(equalTo: badge.topAnchor)
        let bottom = stackView.bottomAnchor.constraint(equalTo: badge.bottomAnchor)
        let leading = stackView.leadingAnchor.constraint(equalTo: badge.leadingAnchor)
        let trailing = badge.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 5)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
        
        return badge
    }
}
