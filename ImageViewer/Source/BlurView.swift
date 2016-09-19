//
//  BlurView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class BlurView: UIView {


    var blurPresentDuration: NSTimeInterval = 0.5
    var blurPresentDelay: NSTimeInterval = 0

    var colorPresentDuration: NSTimeInterval = 0.25
    var colorPresentDelay: NSTimeInterval = 0

    var blurDismissDuration: NSTimeInterval = 0.1
    var blurDismissDelay: NSTimeInterval = 0.4

    var colorDismissDuration: NSTimeInterval = 0.45
    var colorDismissDelay: NSTimeInterval = 0

    var blurTargetOpacity: CGFloat = 1
    var colorTargetOpacity: CGFloat = 1

    var overlayColor = UIColor.blackColor() {
        didSet { colorView.backgroundColor = overlayColor }
    }

    let blurringViewContainer = UIView() //serves as a transparency container for the blurringView as it's not recommended by Apple to apply transparency directly to the UIVisualEffectsView
    let blurringView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    let colorView = UIView()

    convenience init() {

        self.init(frame: CGRect.zero)

        print("BlurView init 🌁")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        blurringViewContainer.alpha = 0

        colorView.backgroundColor = overlayColor
        colorView.alpha = 0

        self.addSubview(blurringViewContainer)
        blurringViewContainer.addSubview(blurringView)
        self.addSubview(colorView)
    }

    deinit {

        print("BlurView deinit 💣")
    }
    
    @available (iOS, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        blurringViewContainer.frame = self.bounds
        blurringView.frame = blurringViewContainer.bounds
        colorView.frame = self.bounds
    }

    func present() {

        UIView.animateWithDuration(blurPresentDuration, delay: blurPresentDelay, options: .CurveLinear, animations: { [weak self] in

            self?.blurringViewContainer.alpha = self!.blurTargetOpacity

            }, completion: nil)

        UIView.animateWithDuration(colorPresentDuration, delay: colorPresentDelay, options: .CurveLinear, animations: { [weak self] in

            self?.colorView.alpha = self!.colorTargetOpacity

            }, completion: nil)
    }

    func dismiss() {

        UIView.animateWithDuration(blurDismissDuration, delay: blurDismissDelay, options: .CurveLinear, animations: { [weak self] in

            self?.blurringViewContainer.alpha = 0

            }, completion: nil)

        UIView.animateWithDuration(colorDismissDuration, delay: colorDismissDelay, options: .CurveLinear, animations: { [weak self] in

            self?.colorView.alpha = 0

            }, completion: nil)
    }
}
