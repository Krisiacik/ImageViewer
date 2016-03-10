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
    private var closeButton: UIButton?
    public var headerView: UIView?
    public var footerView: UIView?
    private var applicationWindow: UIWindow? {
        return UIApplication.sharedApplication().delegate?.window?.flatMap { $0 }
    }
    
    //DATA
    private let viewModel: GalleryViewModel
    private var galleryDelegate = GalleryViewControllerDelegate()
    private var galleryDatasource: GalleryViewControllerDatasource!
    private let fadeInHandler = ImageFadeInHandler()
    private var galleryPagingMode = GalleryPagingMode.Standard
    var currentIndex: Int
    var previousIndex: Int
    private var isHeaderFooterHidden = false
    private var isPortraitOnly = false
    
    //LOCAL CONFIG
    private let configuration: GalleryConfiguration
    private var spinnerColor = UIColor.whiteColor()
    private var spinnerStyle = UIActivityIndicatorViewStyle.White
    private let presentTransitionDuration = 0.25
    private let dismissTransitionDuration = 1.00
    private let closeButtonPadding: CGFloat = 8.0
    private let headerViewMarginTop: CGFloat = 20
    private let swipeToDissmissFadeOutAccelerationFactor: CGFloat = 6
    private let toggleHeaderFooterAnimationDuration = 0.15
    private let closeAnimationDuration = 0.2
    private var closeLayout = CloseButtonLayout.PinRight(25, 16)
    private var headerLayout = HeaderLayout.Center(25)
    private var footerLayout = FooterLayout.Center(25)
    
    //TRANSITIONS
    let presentTransition: GalleryPresentTransition
    let closeTransition: GalleryCloseTransition
    
    //COMPLETION
    var landedPageAtIndexCompletion: ((Int) -> Void)? //called everytime ANY animation stops in the page controller and a page at index is on screen
    var changedPageToIndexCompletion: ((Int) -> Void)? //called after any animation IF & ONLY there is a change in page index compared to before animations started
    
    //IMAGE VC FACTORY
    var imageControllerFactory: ImageViewControllerFactory!
    
    // MARK: - VC Setup
    
    public init(viewModel: GalleryViewModel, configuration: GalleryConfiguration = defaultGalleryConfiguration()) {
        
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
            case .HeaderViewLayout(let layout):     headerLayout = layout
            case .FooterViewLayout(let layout):     footerLayout = layout
            case .CloseLayout(let layout):          closeLayout = layout
            }
        }
        
        self.presentTransition = GalleryPresentTransition(duration: presentTransitionDuration, displacedView: self.viewModel.displacedView)
        self.closeTransition = GalleryCloseTransition(duration: dismissTransitionDuration)
        
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(float: dividerWidth ?? 10)])
        
        self.imageControllerFactory = ImageViewControllerFactory(imageViewModel: viewModel, configuration: configuration, fadeInHandler: fadeInHandler, delegate: self)
        
        //needs to be kept alive with strong reference
        self.galleryDatasource = GalleryViewControllerDatasource(imageControllerFactory: imageControllerFactory, viewModel: viewModel, galleryPagingMode: galleryPagingMode)
        self.delegate = galleryDelegate
        self.dataSource = galleryDatasource
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .Custom
        extendedLayoutIncludesOpaqueBars = true
        
        configurePagingCompletionBlocks()
        configureInitialImageController()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        self.landedPageAtIndexCompletion?(self.currentIndex)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func rotate() {
    
        guard isPortraitOnly else { return } //if the app supports rotation on global level, we don't need to rotate here manually because the rotation of keyWindow will rotate all app's content with it via affine transform and from the perspective of the gallery it is just a simple relayout. Allowing access to remaining code only makes sense if the app is portrait only but we still want to support rotation inside the gallery.

//        let temporaryBlackRotationView = UIView()
//        temporaryBlackRotationView.backgroundColor = UIColor.blackColor()
//        temporaryBlackRotationView.bounds.size = CGSize(width: 1500, height: 1500)
//        temporaryBlackRotationView.center = self.view.boundsCenter
//        self.view.insertSubview(temporaryBlackRotationView, atIndex: 0)

        self.willRotateToInterfaceOrientation(UIApplication.sharedApplication().statusBarOrientation, duration: 1.0)
        
        let aspectFitSize = aspectFitContentSize(forBoundingSize: self.rotationAdjustedBounds().size, contentSize: viewModel.displacedView.bounds.size)
        
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
        
            self.view.transform = self.rotationTransform()
            self.view.bounds = self.rotationAdjustedBounds()
            
            })
            { finished  in
        
//            temporaryBlackRotationView.removeFromSuperview()
        }
    }
    
    private func rotationAdjustedBounds() -> CGRect {
        guard let window = applicationWindow else { return CGRectZero }
        guard isPortraitOnly else {
            return window.bounds
        }
        
        return (UIDevice.currentDevice().orientation.isLandscape) ? CGRect(origin: CGPointZero, size: window.bounds.size.inverted()): window.bounds
    }
    
    private func rotationTransform() -> CGAffineTransform {
        guard isPortraitOnly else {
            return CGAffineTransformIdentity
        }
        
        return CGAffineTransformMakeRotation(degreesToRadians(rotationAngleToMatchDeviceOrientation(UIDevice.currentDevice().orientation)))
    }
    
    private func rotationAngleToMatchDeviceOrientation(orientation: UIDeviceOrientation) -> CGFloat {
        
        var desiredRotationAngle: CGFloat = 0
        
        switch orientation {
        case .LandscapeLeft:                    desiredRotationAngle = 90
        case .LandscapeRight:                   desiredRotationAngle = -90
        case .PortraitUpsideDown:               desiredRotationAngle = 180
        default:                                desiredRotationAngle = 0
        }
        
        return desiredRotationAngle
    }
    
    private func degreesToRadians(degree: CGFloat) -> CGFloat {
        return CGFloat(M_PI) * degree / 180
    }
    
    func configurePagingCompletionBlocks() {
        
        self.landedPageAtIndexCompletion = viewModel.landedPageAtIndexCompletion
        self.changedPageToIndexCompletion = viewModel.changedPageToIndexCompletion
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

        closeButton?.addTarget(self, action: "close", forControlEvents: .TouchUpInside)
    }
    
    func createViewHierarchy() {
        
        if let close = closeButton {

            self.view.addSubview(close)
        }
    }
    
    func configureHeaderView() {
        
        if let header = headerView {
            self.view.addSubview(header)
        }
    }
    
    func configureFooterView() {
        
        if let footer = footerView {
            self.view.addSubview(footer)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        isPortraitOnly = presentingViewController!.supportedInterfaceOrientations() == .Portrait ||
            UIApplication.sharedApplication().supportedInterfaceOrientationsForWindow(nil) == .Portrait
        
        configureHeaderView()
        configureFooterView()
        configureCloseButton()
        createViewHierarchy()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutCloseButton()
        layoutHeaderView()
        layoutFooterView()
    }
    
    func layoutCloseButton() {
        
        if let close = closeButton {
            
            switch closeLayout {
                
            case .PinRight(let marginTop, let marginRight):
                
                close.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
                close.frame.origin.x = self.view.frame.size.width - marginRight - close.frame.size.width
                close.frame.origin.y = marginTop
                
            case .PinLeft(let marginTop, let marginLeft):
                
                close.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
                close.frame.origin.x = marginLeft
                close.frame.origin.y = marginTop
            }
        }
    }
    
    func layoutHeaderView() {
        
        if let header = headerView {
            
            switch headerLayout {
                
            case .Center(let marginTop):
                
                header.center = self.view.boundsCenter
                header.frame.origin.y = marginTop
                
            case .PinBoth(let marginTop, let marginLeft,let marginRight):
                
                header.autoresizingMask = .FlexibleWidth
                header.frame.origin = CGPoint(x: marginLeft, y: marginTop)
                header.frame.size.width = self.view.frame.width - marginLeft - marginRight
                
            case .PinLeft(let marginTop, let marginLeft):
                
                header.autoresizingMask = .FlexibleRightMargin
                header.frame.origin = CGPoint(x: marginLeft, y: marginTop)
                
            case .PinRight(let marginTop, let marginRight):
                
                header.autoresizingMask = .FlexibleLeftMargin
                header.frame.origin = CGPoint(x: self.view.frame.width - marginRight - header.frame.width, y: marginTop)
            }
        }
    }
    
    func layoutFooterView() {
        
        if let footer = footerView {
            
            switch footerLayout {
                
            case .Center(let marginBottom):
                
                footer.autoresizingMask = .FlexibleTopMargin
                footer.center = self.view.boundsCenter
                footer.frame.origin.y = self.view.frame.height - footer.frame.height - marginBottom
                
            case .PinBoth(let marginBottom, let marginLeft,let marginRight):
                
                footer.autoresizingMask = .FlexibleWidth
                footer.frame.origin = CGPoint(x: marginLeft, y: self.view.frame.height - footer.frame.height - marginBottom)
                footer.frame.size.width = self.view.frame.width - marginLeft - marginRight
                
            case .PinLeft(let marginBottom, let marginLeft):
                
                footer.autoresizingMask = .FlexibleRightMargin
                footer.frame.origin = CGPoint(x: marginLeft, y: self.view.frame.height - footer.frame.height - marginBottom)
                
            case .PinRight(let marginBottom, let marginRight):
                
                footer.autoresizingMask = .FlexibleLeftMargin
                footer.frame.origin = CGPoint(x: self.view.frame.width - marginRight - footer.frame.width, y: marginBottom)
            }
        }
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
                
                imageController.closeAnimation(closeAnimationDuration, completion: { [weak self] finished in
                    
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
        
        if isHeaderFooterHidden == false {
            
            let alpha = 1 - distance * swipeToDissmissFadeOutAccelerationFactor
            
            closeButton?.alpha = alpha
            headerView?.alpha = alpha
            footerView?.alpha = alpha
        }
    }
    
    func imageViewControllerDidSingleTap(controller: ImageViewController) {
        
        let alpha: CGFloat = (isHeaderFooterHidden) ? 1 : 0
        
        isHeaderFooterHidden = !isHeaderFooterHidden
        
        UIView.animateWithDuration(toggleHeaderFooterAnimationDuration, animations: { [weak self] in
            
            self?.headerView?.alpha = alpha
            self?.footerView?.alpha = alpha
            self?.closeButton?.alpha = alpha
            
            })
    }
}

public extension UIViewController {
    
    public func presentImageGallery(gallery: GalleryViewController, completion: (Void -> Void)? = {}) {
        presentViewController(gallery, animated: true, completion: completion)
    }
}