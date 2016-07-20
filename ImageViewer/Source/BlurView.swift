//
//  BlurView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class BlurView: UIView {

    var overlayColor = UIColor.blackColor()

    var blur: Float = 0 {
        didSet { applyBlur(blur) }
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

    convenience init() {

        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        blurringView.contentView.backgroundColor = overlayColor
        blurringView.contentView.alpha = 0
        blurringViewContainer.alpha = 0

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

    private func applyBlur(value: Float) {

        let normalizedValue = CGFloat(min(abs(value), 1)) //We are scoping the values to 0..1 interval. A "Percent" foundation type would be nice but this will have to do.

        let blurScopedValue = max(min(normalizedValue, blurThresholdMax), blurThresholdMin) - blurThresholdMin
        let blurRange = blurThresholdMax - blurThresholdMin
        let blurAlpha = CGFloat(blurScopedValue / blurRange)

        let contentScope = max(min(normalizedValue, overlayColorThresholdMax), overlayColorThresholdMin) - overlayColorThresholdMin
        let contentRange = overlayColorThresholdMax - overlayColorThresholdMin
        let contentAlpha = CGFloat(contentScope / contentRange)

        print(blurAlpha)
        print(contentAlpha)

        blurringViewContainer.alpha = blurAlpha
        blurringView.contentView.alpha = 0
    }
}
