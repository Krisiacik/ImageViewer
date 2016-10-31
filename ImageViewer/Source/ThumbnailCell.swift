//
//  ThumbnailsCell.swift
//  ImageViewer
//
//  Created by Zeno Foltin on 07/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {

    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.backgroundColor = UIColor.clearColor()
        imageView.contentMode = .ScaleAspectFit
        self.contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        imageView.frame = bounds
        super.layoutSubviews()
    }
}
