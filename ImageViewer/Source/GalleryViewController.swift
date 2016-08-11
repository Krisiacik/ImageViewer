//
//  GalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

final public class GalleryViewController : UIPageViewController, UIViewControllerTransitioningDelegate, ImageViewControllerDelegate  {
    
    /// UI
    private var closeButton: UIButton?
    private var seeAllButton: UIButton?
    /// You can set any UIView subclass here. If set, it will be integrated into view hierachy and laid out 
    /// following either the default pinning settings or settings from a custom configuration.
    public var headerView: UIView?
    /// Behaves the same way as header view above, the only difference is this one is pinned to the bottom.
    public var footerView: UIView?
    private var applicationWindow: UIWindow? {
        return UIApplication.sharedApplication().delegate?.window?.flatMap { $0 }
    }
    
    /// DATA
    private let imageProvider: ImageProvider
    private let displacedView: UIView
    private let imageCount: Int
    private let startIndex: Int
    
    private var galleryDatasource: GalleryViewControllerDatasource!
    private let fadeInHandler = ImageFadeInHandler()
    private var galleryPagingMode = GalleryPagingMode.Standard
    var currentIndex: Int
    private var isDecorationViewsHidden = false
    private var isAnimating = false
    
    /// LOCAL CONFIG
    private let configuration: GalleryConfiguration
    private var spinnerColor = UIColor.whiteColor()
    private var backgroundColor = UIColor.blackColor()
    private var spinnerStyle = UIActivityIndicatorViewStyle.White
    private let presentTransitionDuration = 0.25
    private let dismissTransitionDuration = 1.00
    private let closeButtonPadding: CGFloat = 8.0
    private let headerViewMarginTop: CGFloat = 20
    private let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6
    private let toggleHeaderFooterAnimationDuration = 0.15
    private let closeAnimationDuration = 0.2
    private let rotationAnimationDuration = 0.2
    private var closeLayout = ButtonLayout.PinLeft(8, 16)
    private var seeAllLayout = ButtonLayout.PinRight(8, 16)
    private var headerLayout = HeaderLayout.Center(25)
    private var footerLayout = FooterLayout.Center(25)
    private var statusBarHidden = true
    
    /// TRANSITIONS
    private let presentTransition: GalleryPresentTransition
    private let closeTransition: GalleryCloseTransition
    
    /// COMPLETION
    /// If set ,the block is executed right after the initial launc hanimations finish.
    public var launchedCompletion: (() -> Void)?
    /// If set, called everytime ANY animation stops in the page controller stops and the viewer passes a page index of the page that is currently on screen
    public var landedPageAtIndexCompletion: ((Int) -> Void)?
    /// If set, launched after all animations finish when the close button is pressed.
    public var closedCompletion: (() -> Void)?
    /// If set, launched after all animations finish when the close() method is invoked via public API.
    public var programaticallyClosedCompletion: (() -> Void)?
    /// If set, launched after all animations finish when the swipe-to-dismiss (applies to all directions and cases) gesture is used.
    public var swipedToDismissCompletion: (() -> Void)?
    
    /// IMAGE VC FACTORY
    private var imageControllerFactory: ImageViewControllerFactory!
    
    // MARK: - VC Setup
    
    public init(imageProvider: ImageProvider, displacedView: UIView, imageCount: Int ,startIndex: Int, configuration: GalleryConfiguration = defaultGalleryConfiguration()) {
        
        self.imageProvider = imageProvider
        self.displacedView = displacedView
        self.imageCount = imageCount
        self.startIndex = startIndex
        self.currentIndex = startIndex
        self.configuration = configuration
        
        var dividerWidth: Float = 10
        
        for item in configuration {
            
            switch item {
                
            case .ImageDividerWidth(let width):             dividerWidth = Float(width)
            case .SpinnerStyle(let style):                  spinnerStyle = style
            case .SpinnerColor(let color):                  spinnerColor = color
            case .CloseButton(let button):                  closeButton = button
            case .SeeAllButton(let button):                 seeAllButton = button
            case .PagingMode(let mode):                     galleryPagingMode = mode
            case .HeaderViewLayout(let layout):             headerLayout = layout
            case .FooterViewLayout(let layout):             footerLayout = layout
            case .CloseLayout(let layout):                  closeLayout = layout
            case .SeeAllLayout(let layout):                 seeAllLayout = layout
            case .StatusBarHidden(let hidden):              statusBarHidden = hidden
            case .HideDecorationViewsOnLaunch(let hidden):  isDecorationViewsHidden = hidden
            case .BackgroundColor(let color):               backgroundColor = color
            }
        }
        self.presentTransition = GalleryPresentTransition(duration: presentTransitionDuration, displacedView: self.displacedView, decorationViewsHidden: isDecorationViewsHidden, backgroundColor: backgroundColor)
        
        self.closeTransition = GalleryCloseTransition(duration: dismissTransitionDuration)
        
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(float: dividerWidth)])
        
        self.imageControllerFactory = ImageViewControllerFactory(imageProvider: imageProvider, displacedView: displacedView, imageCount: imageCount, startIndex: startIndex, configuration: configuration, fadeInHandler: fadeInHandler, delegate: self)
        
        /// Needs to be kept alive with strong reference
        self.galleryDatasource = GalleryViewControllerDatasource(imageControllerFactory: imageControllerFactory, imageCount: imageCount, galleryPagingMode: galleryPagingMode)
        self.dataSource = galleryDatasource
        
        self.transitioningDelegate = self
        self.modalPresentationStyle = .Custom
        self.extendedLayoutIncludesOpaqueBars = true
        self.applicationWindow?.windowLevel = (statusBarHidden) ? UIWindowLevelStatusBar + 1 : UIWindowLevelNormal
        
        configureInitialImageController()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GalleryViewController.rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
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
        overlayView.backgroundColor = backgroundColor
        overlayView.bounds.size = UIScreen.mainScreen().bounds.insetBy(dx: -UIScreen.mainScreen().bounds.width * 2, dy: -UIScreen.mainScreen().bounds.height * 2).size
        overlayView.center = self.view.boundsCenter
        self.presentingViewController?.view.addSubview(overlayView)
        
        return overlayView
    }
    
    // MARK: - Animations
    
    func rotate() {
        
        /// If the app supports rotation on global level, we don't need to rotate here manually because the rotation
        /// of key Window will rotate all app's content with it via affine transform and from the perspective of the
        /// gallery it is just a simple relayout. Allowing access to remaining code only makes sense if the app is 
        /// portrait only but we still want to support rotation inside the gallery.
        guard isPortraitOnly() else { return }
        
        guard UIDevice.currentDevice().orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        let overlayView = applyOverlayView()
        
        UIView.animateWithDuration(rotationAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self] () -> Void in
            
            self?.view.transform = rotationTransform()
            self?.view.bounds = rotationAdjustedBounds()
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
            
            })
        { [weak self] finished  in
            
            overlayView.removeFromSuperview()
            self?.isAnimating = false
        }
    }
    
    // MARK: - Configuration
    
    func configureInitialImageController() {
        
        let initialImageController = self.imageControllerFactory.createImageViewController(startIndex)
        self.setViewControllers([initialImageController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        initialImageController.view.hidden = true
        
        self.presentTransition.completion = { [weak self] in
            initialImageController.view.hidden = false
            
            self?.launchedCompletion?()
        }
    }
    
    private func configureCloseButton() {
        
        closeButton?.addTarget(self, action: #selector(GalleryViewController.interactiveClose), forControlEvents: .TouchUpInside)
    }

    private func configureSeeAllButton() {

        seeAllButton?.addTarget(self, action: #selector(GalleryViewController.seeAll), forControlEvents: .TouchUpInside)
    }

    func createViewHierarchy() {
        
        if let close = closeButton {
            self.view.addSubview(close)
        }

        if let seeAllButton = seeAllButton {
            self.view.addSubview(seeAllButton)
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
        self.presentTransition.seeAllView = self.seeAllButton
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeaderView()
        configureFooterView()
        configureCloseButton()
        configureSeeAllButton()
        configurePresentTransition()
        createViewHierarchy()
    }
    
    // MARK: - Layout
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutCloseButton()
        layoutSeeAll()
        layoutHeaderView()
        layoutFooterView()
    }
    
    func layoutCloseButton() {
        
        guard let close = closeButton else { return }
        
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

    func layoutSeeAll() {

        guard let seeAllButton = seeAllButton else { return }

        switch seeAllLayout {
        case .PinRight(let marginTop, let marginRight):
            seeAllButton.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
            seeAllButton.frame.origin.x = self.view.bounds.size.width - marginRight - seeAllButton.bounds.size.width
            seeAllButton.frame.origin.y = marginTop
        case .PinLeft(let marginTop, let marginLeft):
            seeAllButton.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
            seeAllButton.frame.origin.x = marginLeft
            seeAllButton.frame.origin.y = marginTop
        }
    }

    func layoutHeaderView() {
        
        guard let header = headerView else { return }
        
        switch headerLayout {
            
        case .Center(let marginTop):
            
            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
            header.center = self.view.boundsCenter
            header.frame.origin.y = marginTop
            
        case .PinBoth(let marginTop, let marginLeft,let marginRight):
            
            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleWidth]
            header.bounds.size.width = self.view.bounds.width - marginLeft - marginRight
            header.sizeToFit()
            header.frame.origin = CGPoint(x: marginLeft, y: marginTop)
            
        case .PinLeft(let marginTop, let marginLeft):
            
            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
            header.frame.origin = CGPoint(x: marginLeft, y: marginTop)
            
        case .PinRight(let marginTop, let marginRight):
            
            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
            header.frame.origin = CGPoint(x: self.view.bounds.width - marginRight - header.bounds.width, y: marginTop)
        }
    }
    
    func layoutFooterView() {
        
        guard let footer = footerView else { return }
        
        switch footerLayout {
            
        case .Center(let marginBottom):
            
            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
            footer.center = self.view.boundsCenter
            footer.frame.origin.y = self.view.bounds.height - footer.bounds.height - marginBottom
            
        case .PinBoth(let marginBottom, let marginLeft,let marginRight):
            
            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleWidth]
            footer.frame.size.width = self.view.bounds.width - marginLeft - marginRight
            footer.sizeToFit()
            footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.bounds.height - marginBottom)
            
        case .PinLeft(let marginBottom, let marginLeft):
            
            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleRightMargin]
            footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.bounds.height - marginBottom)
            
        case .PinRight(let marginBottom, let marginRight):
            
            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin]
            footer.frame.origin = CGPoint(x: self.view.bounds.width - marginRight - footer.bounds.width, y: self.view.bounds.height - footer.bounds.height - marginBottom)
            
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
    
    public func close() {
    
        closeWithAnimation(programaticallyClosedCompletion)
    }
    
    func interactiveClose() {
        
        closeWithAnimation(closedCompletion)
     }

    func seeAll() {
        let seeAllController = ThumbnailsViewController(imageProvider: self.imageProvider)
        let closeButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        closeButton.setImage(UIImage(named: "close_normal"), forState: UIControlState.Normal)
        closeButton.setImage(UIImage(named: "close_highlighted"), forState: UIControlState.Highlighted)
        seeAllController.closeButton = closeButton
        seeAllController.closeLayout = closeLayout
        seeAllController.onItemSelected = { index in
            self.goToIndex(index)
        }
        presentViewController(seeAllController, animated: true, completion: nil)
    }

    public func goToIndex(index: Int) {
        guard currentIndex != index && index >= 0 && index < imageCount else { return }

        let imageViewController = self.imageControllerFactory.createImageViewController(index)
        let direction: UIPageViewControllerNavigationDirection = index > currentIndex ? .Forward : .Reverse

        // workaround to make UIPageViewController happy
        if direction == .Forward {
            let previousVC = self.imageControllerFactory.createImageViewController(index - 1)
            setViewControllers([previousVC], direction: direction, animated: true, completion: { finished in
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.setViewControllers([imageViewController], direction: direction, animated: false, completion: nil)
                })
            })
        } else {
            let nextVC = self.imageControllerFactory.createImageViewController(index + 1)
            setViewControllers([nextVC], direction: direction, animated: true, completion: { finished in
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.setViewControllers([imageViewController], direction: direction, animated: false, completion: nil)
                    })
            })
        }
    }

    func closeWithAnimation(completion: (() -> Void)?) {
        
        UIView.animateWithDuration(0.1, animations: { [weak self] in
            
            self?.headerView?.alpha = 0.0
            self?.footerView?.alpha = 0.0
            self?.closeButton?.alpha = 0.0
            self?.seeAllButton?.alpha = 0.0
            
        }) { [weak self] done in
            
            if self?.currentIndex == self?.startIndex {
                
                self?.view.backgroundColor = UIColor.clearColor()
                
                if let imageController = self?.viewControllers?.first as? ImageViewController {
                    
                    imageController.closeAnimation(self?.closeAnimationDuration ?? 0.2, completion: { [weak self] finished in
                        
                        self?.postAnimationClose(completion)
                        })
                }
            }
            else {
                self?.postAnimationClose(completion)
            }
        }
    }
    
    func postAnimationClose(completion: (() -> Void)?) {
        
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(false) {
            
            self.applicationWindow!.windowLevel = UIWindowLevelNormal
            completion?()
        }
    }
    
    // MARK: - Image Controller Delegate
    
    func imageViewController(controller: ImageViewController, didSwipeToDismissWithDistanceToEdge distance: CGFloat) {
        
        self.view.backgroundColor = (distance == 0) ? backgroundColor : UIColor.clearColor()
        
        if isDecorationViewsHidden == false {
            
            let alpha = 1 - distance * swipeToDismissFadeOutAccelerationFactor
            
            closeButton?.alpha = alpha
            seeAllButton?.alpha = alpha
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
            self?.seeAllButton?.alpha = alpha
            })
    }
    
    func imageViewControllerDidAppear(controller: ImageViewController) {
        
        self.currentIndex = controller.index
        self.landedPageAtIndexCompletion?(self.currentIndex)
        self.headerView?.sizeToFit()
        self.footerView?.sizeToFit()
    }
}