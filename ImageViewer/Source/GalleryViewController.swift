//
//  GalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit


public class GalleryViewController : UIPageViewController   {
    
    private var closeButton: UIButton!
    private let viewModel: GalleryViewModel
    private let datasource: GalleryViewControllerDatasource
    private var closeButtonSize              = CGSize(width: 50, height: 50)
    private let closeButtonPadding: CGFloat  = 8.0
    
    init(viewModel: GalleryViewModel) {
        
        self.viewModel = viewModel
        datasource = GalleryViewControllerDatasource(viewModel: viewModel)
        
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(int: 10)])

        self.dataSource = datasource
        
        let initialImageController = ImageViewController(imageViewModel: viewModel, imageIndex: viewModel.startIndex, showDisplacedImage: true)
        self.setViewControllers([initialImageController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        configureCloseButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCloseButton() {
        
        closeButton = UIButton()
        closeButton.setImage(UIImage(named: "close_normal"), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "close_highlighted"), forState: UIControlState.Highlighted)
        closeButton.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
        self.view.addSubview(closeButton)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeButton.frame.size = closeButtonSize
        closeButton.frame.origin = CGPoint(x: self.view.frame.size.width - closeButtonSize.width - closeButtonPadding, y: closeButtonPadding)
    }
    
    func close() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}

public extension UIViewController {
    
    public func presentImageGallery(gallery: GalleryViewController, completion: (Void -> Void)? = {}) {
        presentViewController(gallery, animated: false, completion: completion)
    }
}