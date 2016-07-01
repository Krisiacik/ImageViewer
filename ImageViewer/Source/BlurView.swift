//
//  BlurView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class BlurView: UIView {
    
    var blurValue: CGFloat = 0 {
        didSet {
            
            
        }
    }
    
    
    let blurringViewContainer = UIView()
    let blurringView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(blurringViewContainer)
        blurringViewContainer.addSubview(blurringView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurringViewContainer.frame = self.bounds
        blurringView.frame = blurringViewContainer.bounds
    }
}
