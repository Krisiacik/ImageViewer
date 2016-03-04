//
//  GalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit


public class GalleryViewController : UIPageViewController, UIViewControllerTransitioningDelegate, ImageViewControllerDelegate  {
    
    private var closeButton: UIButton!
    private let viewModel: GalleryViewModel
    private var datasource: GalleryViewControllerDatasource!
    private var closeButtonSize = CGSize(width: 50, height: 50)
    private let closeButtonPadding: CGFloat = 8.0
    private let fadeInHandler = ImageFadeInHandler()

    //LOCAL CONFIG
    private let presentTransitionDuration = 0.25
    private let dismissTransitionDuration = 1.00
    
    //TRANSITIONS
    let presentTransition: GalleryPresentTransition
    let closeTransition: GalleryCloseTransition
    
    init(viewModel: GalleryViewModel) {
        
        self.viewModel = viewModel
        self.presentTransition = GalleryPresentTransition(duration: presentTransitionDuration, displacedView: self.viewModel.displacedView)
        self.closeTransition = GalleryCloseTransition(duration: dismissTransitionDuration)

        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(int: 10)])
        
        self.datasource = GalleryViewControllerDatasource(viewModel: viewModel, fadeInHandler: self.fadeInHandler, imageControllerDelegate: self) //it needs to be kept alive with strong reference

        self.dataSource = datasource
        self.transitioningDelegate = self
        self.modalPresentationStyle = .Custom
        extendedLayoutIncludesOpaqueBars = true

        configureInitialImageController()
        configureCloseButton()
        createViewHierarchy()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureInitialImageController() {
        
        let initialImageController = ImageViewController(imageViewModel: viewModel, imageIndex: viewModel.startIndex, showDisplacedImage: true, fadeInHandler: fadeInHandler, delegate: self)
        self.setViewControllers([initialImageController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        initialImageController.view.hidden = true
        
        self.presentTransition.completion = {
            initialImageController.view.hidden = false
        }
    }
    
    private func configureCloseButton() {
        
        closeButton = UIButton()
        closeButton.setImage(UIImage(named: "close_normal"), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "close_highlighted"), forState: UIControlState.Highlighted)
        closeButton.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
        closeButton.userInteractionEnabled = true
    }
    
    func createViewHierarchy() {
        
        self.view.addSubview(closeButton)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeButton.frame.size = closeButtonSize
        closeButton.frame.origin = CGPoint(x: self.view.frame.size.width - closeButtonSize.width - closeButtonPadding, y: closeButtonPadding)
    }
 
    // MARK: - Transitioning Delegate
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    func close() {
        
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageViewController(controller: ImageViewController, swipeToDismissDistanceToEdge distance: CGFloat) {

        self.view.backgroundColor = (distance == 0) ? UIColor.blackColor() : UIColor.clearColor()
        closeButton.alpha = 1 - distance * 4
    }
}

public extension UIViewController {
    
    public func presentImageGallery(gallery: GalleryViewController, completion: (Void -> Void)? = {}) {
        presentViewController(gallery, animated: true, completion: completion)
    }
}