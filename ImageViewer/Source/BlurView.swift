//
//  BlurView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class BlurView: UIView {

    var blurOpacity: CGFloat = 1
    var colorOpacity: CGFloat = 1

    var overlayColor = UIColor.whiteColor() {
        didSet { colorView.backgroundColor = overlayColor }
    }

    /// The following two pairs of values allow us to tweak the pace and thresholds at which the two distint effect layers kick-in, when they create a final composited blur layer.
    /// One is the transparency of the blur layer, the other one is transparency of the color overlay layer. The color overlay layer is on top of the blurring layer. The "Blur value" goes from 0 to 1
    /// But we would want for example the blur layer to be applied faster so we set this from 0 to 0.5 which means that at 0 the transparency of the blur layer will be full ie it will be invisible, and at 0.5 it will be fully visible. We can set the same thing for the color overlay layer. By tweaking these values we can achive a visually pleasing effect.

    /// Represents the range (on a scale of 0 to 1) in which the blur goes from nothing to fully applied.
    var blurThresholdMin: CGFloat = 0
    var blurThresholdMax: CGFloat = 0.3

    /// Represents the range (on a scale of 0 to 1) in which the overlay color transparency goes from nothing to fully applied.
    var overlayColorThresholdMin: CGFloat = 0.1
    var overlayColorThresholdMax: CGFloat = 1


    let blurringViewContainer = UIView() //serves as a transparency container for the blurringView as it's not recommended by Apple to apply transparency directly to the UIVisualEffectsView
    let blurringView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    let colorView = UIView()

    convenience init() {

        self.init(frame: CGRect.zero)
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
    
    @available (iOS, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        blurringViewContainer.frame = self.bounds
        blurringView.frame = blurringViewContainer.bounds
        colorView.frame = self.bounds
    }

    func animate(duration: NSTimeInterval) {

        UIView.animateWithDuration(duration * 0.4) {
            self.blurringViewContainer.alpha = self.blurOpacity
        }
        UIView.animateWithDuration(duration * 0.7, delay: duration * 0.3, options: .CurveLinear, animations: { 

            self.colorView.alpha = self.colorOpacity
            }, completion: nil)
    }

    func present(duration: NSTimeInterval) {

        UIView.animateWithDuration(duration * 0.4) {
            self.blurringViewContainer.alpha = self.blurOpacity
        }

        UIView.animateWithDuration(duration * 0.7, delay: duration * 0.3, options: .CurveLinear, animations: {

            self.colorView.alpha = self.colorOpacity
            }, completion: nil)
    }

    func dismiss() {

        UIView.animateWithDuration(0.3) {
            self.blurringViewContainer.alpha = 0
        }

        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {

            self.colorView.alpha = 0
            }, completion: nil)
    }
}
