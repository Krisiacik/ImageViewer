//
//  ImageCounterView.swift
//  Money
//
//  Created by Kristian Angyal on 07/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import UIKit

class CounterView: UIView {
    
    let count: Int
    let countLabel = UILabel()
    var currentIndex: Int {
        didSet {
            updateLabel()
        }
    }
    
    init(frame: CGRect, currentIndex: Int, count: Int) {
        
        self.currentIndex = currentIndex
        self.count = count
        
        super.init(frame: frame)
        
        configureLabel()
        updateLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        
        countLabel.textAlignment = .Center
        self.addSubview(countLabel)
    }
    
    func updateLabel() {
        
        let stringTemplate = "%d of %d"
        let countString = String(format: stringTemplate, arguments: [currentIndex + 1, count])
        
        countLabel.attributedText = NSAttributedString(string: countString, attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(17), NSForegroundColorAttributeName: UIColor.whiteColor()])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countLabel.frame = self.bounds
    }
}
