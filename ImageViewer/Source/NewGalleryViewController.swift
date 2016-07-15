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
    let blurView = BlurView()
    
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
        
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
        
        let transparencySCrubber = UISlider(frame: CGRect(origin: CGPoint(x: 20, y: 200), size: CGSize(width: 250, height: 40)))
        transparencySCrubber.minimumValue = 0
        transparencySCrubber.maximumValue = 1000
        transparencySCrubber.value = 0
        transparencySCrubber.addTarget(self, action: #selector(transparencyValueChanged), forControlEvents: UIControlEvents.ValueChanged)
        view.addSubview(transparencySCrubber)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        blurView.frame = view.bounds
    }
    
    func transparencyValueChanged(sender: UISlider) {

        blurView.blur = sender.value / 1000

    }
}
