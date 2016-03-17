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
    private var galleryDatasource: GalleryViewControllerDatasource!
    private let fadeInHandler = ImageFadeInHandler()
    private var galleryPagingMode = GalleryPagingMode.Standard
    var currentIndex: Int
    var previousIndex: Int
    private var isDecorationViewsHidden = false
    private var isAnimating = false
    
    //LOCAL CONFIG
    private let configuration: GalleryConfiguration
    private var spinnerColor = UIColor.whiteColor()
    private var spinnerStyle = UIActivityIndicatorViewStyle.White
    private let presentTransitionDuration = 0.25
    private let dismissTransitionDuration = 1.00
    private let closeButtonPadding: CGFloat = 8.0
    private let headerViewMarginTop: CGFloat = 20
    private let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6
    private let toggleHeaderFooterAnimationDuration = 0.15
    private let closeAnimationDuration = 0.2
    private let rotationAnimationDuration = 0.2
    private var closeLayout = CloseButtonLayout.PinRight(25, 16)
    private var headerLayout = HeaderLayout.Center(25)
    private var footerLayout = FooterLayout.Center(25)
    private var statusBarHidden = true
    
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
                
            case .ImageDividerWidth(let width):             dividerWidth = Float(width)
            case .SpinnerStyle(let style):                  spinnerStyle = style
            case .SpinnerColor(let color):                  spinnerColor = color
            case .CloseButton(let button):                  closeButton = button
            case .PagingMode(let mode):                     galleryPagingMode = mode
            case .HeaderViewLayout(let layout):             headerLayout = layout
            case .FooterViewLayout(let layout):             footerLayout = layout
            case .CloseLayout(let layout):                  closeLayout = layout
            case .StatusBarHidden(let hidden):              statusBarHidden = hidden
            case .HideDecorationViewsOnLaunch(let hidden):    isDecorationViewsHidden = hidden
            
            }
        }
        
        self.presentTransition = GalleryPresentTransition(duration: presentTransitionDuration, displacedView: self.viewModel.displacedView , decorationViewsHidden: isDecorationViewsHidden)
        self.closeTransition = GalleryCloseTransition(duration: dismissTransitionDuration)
        
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(float: dividerWidth ?? 10)])
        
        self.imageControllerFactory = ImageViewControllerFactory(imageViewModel: viewModel, configuration: configuration, fadeInHandler: fadeInHandler, delegate: self)
        
        //needs to be kept alive with strong reference
        self.galleryDatasource = GalleryViewControllerDatasource(imageControllerFactory: imageControllerFactory, viewModel: viewModel, galleryPagingMode: galleryPagingMode)
        self.dataSource = galleryDatasource
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .Custom
        self.extendedLayoutIncludesOpaqueBars = true
        self.applicationWindow?.windowLevel = (statusBarHidden) ? UIWindowLevelStatusBar + 1 : UIWindowLevelNormal
        
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
    
    func applyOverlayView() -> UIView {
        
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.blackColor()
        overlayView.bounds.size = UIScreen.mainScreen().bounds.insetBy(dx: -UIScreen.mainScreen().bounds.width * 2, dy: -UIScreen.mainScreen().bounds.height * 2).size
        overlayView.center = self.view.boundsCenter
        self.presentingViewController?.view.addSubview(overlayView)
        
        return overlayView
    }
    
    // MARK: - Animations
    
    func rotate() {

        guard isPortraitOnly() else { return } //if the app supports rotation on global level, we don't need to rotate here manually because the rotation of keyWindow will rotate all app's content with it via affine transform and from the perspective of the gallery it is just a simple relayout. Allowing access to remaining code only makes sense if the app is portrait only but we still want to support rotation inside the gallery.
        
        guard UIDevice.currentDevice().orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        let overlayView = applyOverlayView()
        
        UIView.animateWithDuration(rotationAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in

            self.view.transform = rotationTransform()
            self.view.bounds = rotationAdjustedBounds()
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            
            })
            { [weak self] finished  in

            overlayView.removeFromSuperview()
                self?.isAnimating = false
        }
    }
    
    // MARK: - Configuration
    
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
    
    func configurePresentTransition() {
        
        self.presentTransition.headerView = self.headerView
        self.presentTransition.footerView = self.footerView
        self.presentTransition.closeView = self.closeButton
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeaderView()
        configureFooterView()
        configureCloseButton()
        configurePresentTransition()
        createViewHierarchy()
    }
    
    // MARK: - Layout
    
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
                close.frame.origin.x = self.view.bounds.size.width - marginRight - close.bounds.size.width
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
                header.bounds.size.width = self.view.bounds.width - marginLeft - marginRight
                
            case .PinLeft(let marginTop, let marginLeft):
                
                header.autoresizingMask = .FlexibleRightMargin
                header.frame.origin = CGPoint(x: marginLeft, y: marginTop)
                
            case .PinRight(let marginTop, let marginRight):
                
                header.autoresizingMask = .FlexibleLeftMargin
                header.frame.origin = CGPoint(x: self.view.bounds.width - marginRight - header.bounds.width, y: marginTop)
            }
        }
    }
    
    func layoutFooterView() {
        
        if let footer = footerView {
            
            switch footerLayout {
                
            case .Center(let marginBottom):
                
                footer.autoresizingMask = .FlexibleTopMargin
                footer.center = self.view.boundsCenter
                footer.frame.origin.y = self.view.bounds.height - footer.bounds.height - marginBottom
                
            case .PinBoth(let marginBottom, let marginLeft,let marginRight):
                
                footer.autoresizingMask = .FlexibleWidth
                footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.bounds.height - marginBottom)
                footer.frame.size.width = self.view.bounds.width - marginLeft - marginRight
                
            case .PinLeft(let marginBottom, let marginLeft):
                
                footer.autoresizingMask = .FlexibleRightMargin
                footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.frame.height - marginBottom)
                
            case .PinRight(let marginBottom, let marginRight):
                
                footer.autoresizingMask = .FlexibleLeftMargin
                footer.frame.origin = CGPoint(x: self.view.bounds.width - marginRight - footer.bounds.width, y: marginBottom)
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
        
        UIView.animateWithDuration(0.1, animations: { [weak self] in
            
            self?.headerView?.alpha = 0.0
            self?.footerView?.alpha = 0.0
            self?.closeButton?.alpha = 0.0
            
            }) { [weak self] done in
              
                if self?.currentIndex == self?.viewModel.startIndex {
                    
                    self?.view.backgroundColor = UIColor.clearColor()
                    
                    if let imageController = self?.viewControllers?.first as? ImageViewController {
                        
                        imageController.closeAnimation(self?.closeAnimationDuration ?? 0.2, completion: { [weak self] finished in
                            
                            self?.innerClose()
                            })
                    }
                }
                else {
                    self?.innerClose()
                }
                
        }
    }
    
    func innerClose() {
        
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(true) {
        
            self.applicationWindow!.windowLevel = UIWindowLevelNormal
        }
    }
    
    // MARK: - Image Controller Delegate
    
    func imageViewController(controller: ImageViewController, didSwipeToDismissWithDistanceToEdge distance: CGFloat) {
        
        self.view.backgroundColor = (distance == 0) ? UIColor.blackColor() : UIColor.clearColor()
        
        if isDecorationViewsHidden == false {
            
            let alpha = 1 - distance * swipeToDismissFadeOutAccelerationFactor
            
            closeButton?.alpha = alpha
            headerView?.alpha = alpha
            footerView?.alpha = alpha
        }
    }
    
    func imageViewControllerDidSingleTap(controller: ImageViewController) {
        
        let alpha: CGFloat = (isDecorationViewsHidden) ? 1 : 0
        
        isDecorationViewsHidden = !isDecorationViewsHidden
        
        UIView.animateWithDuration(toggleHeaderFooterAnimationDuration, animations: { [weak self] in
            
            self?.headerView?.alpha = alpha
            self?.footerView?.alpha = alpha
            self?.closeButton?.alpha = alpha
            
            })
    }
    
    func imageViewControllerDidAppear(controller: ImageViewController) {
        
        self.currentIndex = controller.index
        self.landedPageAtIndexCompletion?(self.currentIndex)
    }
}

public extension UIViewController {
    
    public func presentImageGallery(gallery: GalleryViewController, completion: (Void -> Void)? = {}) {
        presentViewController(gallery, animated: true, completion: completion)
    }
}