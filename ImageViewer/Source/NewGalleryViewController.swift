//
//  NewGalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public class NewGalleryViewController: UIPageViewController {

    //VIEWS
    let overlayView = UIVisualEffectView(effect: nil)
    
    /// CONFIGURATION
    private var spineDividerWidth: Float = 10
    
    init(startIndex: Int, itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource? = nil, configuration: GalleryConfiguration = []) {
        
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll,
                   navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal,
                   options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(float: spineDividerWidth)])
        
        configureInitialImageController(itemsDatasource, displacedViewsDatasource: displacedViewsDatasource, configuration: configuration)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureInitialImageController(itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource? = nil, configuration: GalleryConfiguration = []) {
        
        let initialImageController = GalleryItemViewController(itemsDatasource: itemsDatasource, displacedViewsDatasource: displacedViewsDatasource, configuration: configuration)
        
        self.setViewControllers([initialImageController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        
        self.modalPresentationStyle = .OverFullScreen
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(overlayView)
        view.sendSubviewToBack(overlayView)
        
        overlayView.contentView.alpha = 0
        overlayView.contentView.backgroundColor = UIColor.blackColor()
        
        let transparencySCrubber = UISlider(frame: CGRect(origin: CGPoint(x: 20, y: 200), size: CGSize(width: 250, height: 40)))
        transparencySCrubber.minimumValue = 0
        transparencySCrubber.maximumValue = 1000
        transparencySCrubber.value = 0
        transparencySCrubber.addTarget(self, action: #selector(transparencyValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(transparencySCrubber)
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        overlayView.layer.speed = 0

        UIView.animateWithDuration(1) { 

            self.overlayView.effect = UIBlurEffect(style: .Light)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        overlayView.frame = view.bounds
    }
    
    func transparencyValueChanged(sender: UISlider) {
        
        let blurMin:Float = 0
        let blurMax: Float = 500
        let blurScopedValue = max(min(sender.value, blurMax), blurMin) - blurMin
        let blurRange = blurMax - blurMin
        let blurAlpha = CGFloat(blurScopedValue / blurRange)
        
        let contentMin:Float = 0
        let contentMax: Float = 800
        let contentScope = max(min(sender.value, contentMax), contentMin) - contentMin
        let contentRange = contentMax - contentMin
        let contentAlpha = CGFloat(contentScope / contentRange)

        overlayView.layer.timeOffset = CFTimeInterval(blurAlpha / 2)
        overlayView.contentView.alpha = contentAlpha

    }
}
