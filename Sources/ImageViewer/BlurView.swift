//
//  BlurView.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class BlurView: UIView {

    var blurPresentDuration: TimeInterval = 0.5
    var blurPresentDelay: TimeInterval = 0

    var colorPresentDuration: TimeInterval = 0.25
    var colorPresentDelay: TimeInterval = 0

    var blurDismissDuration: TimeInterval = 0.1
    var blurDismissDelay: TimeInterval = 0.4

    var colorDismissDuration: TimeInterval = 0.45
    var colorDismissDelay: TimeInterval = 0

    var blurTargetOpacity: CGFloat = 1
    var colorTargetOpacity: CGFloat = 1

    var overlayColor = UIColor.black {
        didSet { colorView.backgroundColor = overlayColor }
    }

    let blurringViewContainer = UIView() //serves as a transparency container for the blurringView as it's not recommended by Apple to apply transparency directly to the UIVisualEffectsView
    let blurringView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
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

    func present() {

        UIView.animate(withDuration: blurPresentDuration, delay: blurPresentDelay, options: .curveLinear, animations: { [weak self] in

            self?.blurringViewContainer.alpha = self!.blurTargetOpacity

            }, completion: nil)

        UIView.animate(withDuration: colorPresentDuration, delay: colorPresentDelay, options: .curveLinear, animations: { [weak self] in

            self?.colorView.alpha = self!.colorTargetOpacity

            }, completion: nil)
    }

    func dismiss() {

        UIView.animate(withDuration: blurDismissDuration, delay: blurDismissDelay, options: .curveLinear, animations: { [weak self] in

            self?.blurringViewContainer.alpha = 0

            }, completion: nil)

        UIView.animate(withDuration: colorDismissDuration, delay: colorDismissDelay, options: .curveLinear, animations: { [weak self] in

            self?.colorView.alpha = 0

            }, completion: nil)
    }
}
