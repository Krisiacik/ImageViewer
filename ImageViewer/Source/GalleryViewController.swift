//
//  GalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit


public class GalleryViewController : UIPageViewController, UIViewControllerTransitioningDelegate, ImageViewControllerDelegate  {
    
    //UI
    private var closeButton: UIButton!
    
    //DATA
    private let viewModel: GalleryViewModel
    private var galleryDelegate = GalleryViewControllerDelegate()
    private var galleryDatasource: GalleryViewControllerDatasource!
    private let fadeInHandler = ImageFadeInHandler()
    private var galleryPagingMode = GalleryPagingMode.Standard
    var currentIndex: Int
    var previousIndex: Int
    
    //LOCAL CONFIG
    private let configuration: [GalleryConfiguration]
    private var spinnerColor = UIColor.whiteColor()
    private var spinnerStyle = UIActivityIndicatorViewStyle.White
    private let presentTransitionDuration = 0.25
    private let dismissTransitionDuration = 1.00
    private let closeButtonPadding: CGFloat = 8.0
    
    //TRANSITIONS
    let presentTransition: GalleryPresentTransition
    let closeTransition: GalleryCloseTransition
    
    //COMPLETION
    var landedPageAtIndexCompletion: ((Int) -> Void)? //called everytime ANY animation stops in the page controller and a page at index is on screen
    var changedPageToIndexCompletion: ((Int) -> Void)? //called after any animation IF & ONLY there is a change in page index compared to before animations started
    
    //IMAGE VC FACTORY
    var imageControllerFactory: ImageViewControllerFactory!
    
    // MARK: - VC Setup
    
    public init(viewModel: GalleryViewModel, configuration: [GalleryConfiguration] = defaultGalleryConfiguration()) {
        
        self.viewModel = viewModel
        self.configuration = configuration
        self.currentIndex = viewModel.startIndex
        self.previousIndex = viewModel.startIndex
        
        var dividerWidth: Float?
        
        for item in configuration {
            
            switch item {
                
            case .ImageDividerWidth(let width):     dividerWidth = Float(width)
            case .SpinnerStyle(let style):          spinnerStyle = style
            case .SpinnerColor(let color):          spinnerColor = color
            case .CloseButton(let button):          closeButton = button
            case .PagingMode(let mode):             galleryPagingMode = mode
            }
        }
        
        self.presentTransition = GalleryPresentTransition(duration: presentTransitionDuration, displacedView: self.viewModel.displacedView)
        self.closeTransition = GalleryCloseTransition(duration: dismissTransitionDuration)
        
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(float: dividerWidth ?? 10)])
        
        self.imageControllerFactory = ImageViewControllerFactory(imageViewModel: viewModel, configuration: configuration, fadeInHandler: fadeInHandler, delegate: self)
        
        //needs to be kept alive with strong reference
        self.galleryDatasource = GalleryViewControllerDatasource(imageControllerFactory: imageControllerFactory, viewModel: viewModel,             galleryPagingMode: galleryPagingMode)
        self.delegate = galleryDelegate
        self.dataSource = galleryDatasource
        
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
        
        let initialImageController = ImageViewController(imageViewModel: viewModel, configuration: configuration, imageIndex: viewModel.startIndex, showDisplacedImage: true, fadeInHandler: fadeInHandler, delegate: self)
        self.setViewControllers([initialImageController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        initialImageController.view.hidden = true
        
        self.presentTransition.completion = {
            initialImageController.view.hidden = false
        }
    }
    
    private func configureCloseButton() {
        
        closeButton.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
    }
    
    func createViewHierarchy() {
        
        self.view.addSubview(closeButton)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeButton.frame.origin = CGPoint(x: self.view.frame.size.width - closeButton.frame.size.width - closeButtonPadding, y: closeButtonPadding)
    }
    
    // MARK: - Transitioning Delegate
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    // MARK: - Actions
    
    func close() {
        
        if currentIndex == viewModel.startIndex {
            
            self.view.backgroundColor = UIColor.clearColor()
            
            if let imageController = self.viewControllers?.first as? ImageViewController {
                
                imageController.closeAnimation(0.2, completion: { [weak self] finished in
                    
                    self?.innerClose()
                })
            }
        }
        else {
            innerClose()
        }
    }
    
    func innerClose() {
     
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Image Controller Delegate
    
    func imageViewController(controller: ImageViewController, didSwipeToDismissWithDistanceToEdge distance: CGFloat) {
        
        self.view.backgroundColor = (distance == 0) ? UIColor.blackColor() : UIColor.clearColor()
        closeButton.alpha = 1 - distance * 4
    }
}

public extension UIViewController {
    
    public func presentImageGallery(gallery: GalleryViewController, completion: (Void -> Void)? = {}) {
        presentViewController(gallery, animated: true, completion: completion)
    }
}