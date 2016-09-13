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
    fileprivate var closeButton: UIButton?
    fileprivate var seeAllButton: UIButton?
    /// You can set any UIView subclass here. If set, it will be integrated into view hierachy and laid out 
    /// following either the default pinning settings or settings from a custom configuration.
    public var headerView: UIView?
    /// Behaves the same way as header view above, the only difference is this one is pinned to the bottom.
    public var footerView: UIView?
    fileprivate var applicationWindow: UIWindow? {
        return UIApplication.shared.delegate?.window?.flatMap { $0 }
    }
    
    /// DATA
    fileprivate let imageProvider: ImageProvider
    fileprivate let displacedView: UIView
    fileprivate let imageCount: Int
    fileprivate let startIndex: Int
    
    fileprivate var galleryDatasource: GalleryViewControllerDatasource!
    fileprivate let fadeInHandler = ImageFadeInHandler()
    fileprivate var galleryPagingMode = GalleryPagingMode.standard
    var currentIndex: Int
    fileprivate var isDecorationViewsHidden = false
    fileprivate var isAnimating = false
    
    /// LOCAL CONFIG
    fileprivate let configuration: GalleryConfiguration
    fileprivate var spinnerColor = UIColor.white
    fileprivate var backgroundColor = UIColor.black
    fileprivate var spinnerStyle = UIActivityIndicatorViewStyle.white
    fileprivate let presentTransitionDuration = 0.25
    fileprivate let dismissTransitionDuration = 1.00
    fileprivate let closeButtonPadding: CGFloat = 8.0
    fileprivate let headerViewMarginTop: CGFloat = 20
    fileprivate let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6
    fileprivate let toggleHeaderFooterAnimationDuration = 0.15
    fileprivate let closeAnimationDuration = 0.2
    fileprivate let rotationAnimationDuration = 0.2
    fileprivate var closeLayout = ButtonLayout.pinLeft(8, 16)
    fileprivate var seeAllLayout = ButtonLayout.pinRight(8, 16)
    fileprivate var headerLayout = HeaderLayout.center(25)
    fileprivate var footerLayout = FooterLayout.center(25)
    fileprivate var statusBarHidden = true
    
    /// TRANSITIONS
    fileprivate let presentTransition: GalleryPresentTransition
    fileprivate let closeTransition: GalleryCloseTransition
    
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
    fileprivate var imageControllerFactory: ImageViewControllerFactory!
    
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
                
            case .imageDividerWidth(let width):             dividerWidth = Float(width)
            case .spinnerStyle(let style):                  spinnerStyle = style
            case .spinnerColor(let color):                  spinnerColor = color
            case .closeButton(let button):                  closeButton = button
            case .seeAllButton(let button):                 seeAllButton = button
            case .pagingMode(let mode):                     galleryPagingMode = mode
            case .headerViewLayout(let layout):             headerLayout = layout
            case .footerViewLayout(let layout):             footerLayout = layout
            case .closeLayout(let layout):                  closeLayout = layout
            case .seeAllLayout(let layout):                 seeAllLayout = layout
            case .statusBarHidden(let hidden):              statusBarHidden = hidden
            case .hideDecorationViewsOnLaunch(let hidden):  isDecorationViewsHidden = hidden
            case .backgroundColor(let color):               backgroundColor = color
            }
        }
        self.presentTransition = GalleryPresentTransition(duration: presentTransitionDuration, displacedView: self.displacedView, decorationViewsHidden: isDecorationViewsHidden, backgroundColor: backgroundColor)
        
        self.closeTransition = GalleryCloseTransition(duration: dismissTransitionDuration)
        
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(value: dividerWidth)])
        
        self.imageControllerFactory = ImageViewControllerFactory(imageProvider: imageProvider, displacedView: displacedView, imageCount: imageCount, startIndex: startIndex, configuration: configuration, fadeInHandler: fadeInHandler, delegate: self)
        
        /// Needs to be kept alive with strong reference
        self.galleryDatasource = GalleryViewControllerDatasource(imageControllerFactory: imageControllerFactory, imageCount: imageCount, galleryPagingMode: galleryPagingMode)
        self.dataSource = galleryDatasource
        
        self.view.backgroundColor = backgroundColor
        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom
        self.extendedLayoutIncludesOpaqueBars = true
        self.applicationWindow?.windowLevel = (statusBarHidden) ? UIWindowLevelStatusBar + 1 : UIWindowLevelNormal
        
        configureInitialImageController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GalleryViewController.rotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.landedPageAtIndexCompletion?(self.currentIndex)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applyOverlayView() -> UIView {
        
        let overlayView = UIView()
        overlayView.backgroundColor = backgroundColor
        overlayView.bounds.size = UIScreen.main.bounds.insetBy(dx: -UIScreen.main.bounds.width * 2, dy: -UIScreen.main.bounds.height * 2).size
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
        
        guard UIDevice.current.orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        let overlayView = applyOverlayView()
        
        UIView.animate(withDuration: rotationAnimationDuration, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { [weak self] () -> Void in
            
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
        self.setViewControllers([initialImageController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        initialImageController.view.isHidden = false
        
        self.presentTransition.completion = { [weak self] in
            self?.launchedCompletion?()
        }
    }
    
    private func configureCloseButton() {
        
        closeButton?.addTarget(self, action: #selector(GalleryViewController.interactiveClose), for: .touchUpInside)
    }

    private func configureSeeAllButton() {

        seeAllButton?.addTarget(self, action: #selector(GalleryViewController.seeAll), for: .touchUpInside)
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
            
        case .pinRight(let marginTop, let marginRight):
            
            close.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
            close.frame.origin.x = self.view.bounds.size.width - marginRight - close.bounds.size.width
            close.frame.origin.y = marginTop
            
        case .pinLeft(let marginTop, let marginLeft):
            
            close.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
            close.frame.origin.x = marginLeft
            close.frame.origin.y = marginTop
        }
    }

    func layoutSeeAll() {

        guard let seeAllButton = seeAllButton else { return }

        switch seeAllLayout {
        case .pinRight(let marginTop, let marginRight):
            seeAllButton.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
            seeAllButton.frame.origin.x = self.view.bounds.size.width - marginRight - seeAllButton.bounds.size.width
            seeAllButton.frame.origin.y = marginTop
        case .pinLeft(let marginTop, let marginLeft):
            seeAllButton.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
            seeAllButton.frame.origin.x = marginLeft
            seeAllButton.frame.origin.y = marginTop
        }
    }

    func layoutHeaderView() {
        
        guard let header = headerView else { return }
        
        switch headerLayout {
            
        case .center(let marginTop):
            
            header.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
            header.center = self.view.boundsCenter
            header.frame.origin.y = marginTop
            
        case .pinBoth(let marginTop, let marginLeft,let marginRight):
            
            header.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
            header.bounds.size.width = self.view.bounds.width - marginLeft - marginRight
            header.sizeToFit()
            header.frame.origin = CGPoint(x: marginLeft, y: marginTop)
            
        case .pinLeft(let marginTop, let marginLeft):
            
            header.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
            header.frame.origin = CGPoint(x: marginLeft, y: marginTop)
            
        case .pinRight(let marginTop, let marginRight):
            
            header.autoresizingMask = [.flexibleBottomMargin, .flexibleLeftMargin]
            header.frame.origin = CGPoint(x: self.view.bounds.width - marginRight - header.bounds.width, y: marginTop)
        }
    }
    
    func layoutFooterView() {
        
        guard let footer = footerView else { return }
        
        switch footerLayout {
            
        case .center(let marginBottom):
            
            footer.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
            footer.center = self.view.boundsCenter
            footer.frame.origin.y = self.view.bounds.height - footer.bounds.height - marginBottom
            
        case .pinBoth(let marginBottom, let marginLeft,let marginRight):
            
            footer.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
            footer.frame.size.width = self.view.bounds.width - marginLeft - marginRight
            footer.sizeToFit()
            footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.bounds.height - marginBottom)
            
        case .pinLeft(let marginBottom, let marginLeft):
            
            footer.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin]
            footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.bounds.height - marginBottom)
            
        case .pinRight(let marginBottom, let marginRight):
            
            footer.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin]
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
        closeButton.setImage(UIImage(named: "close_normal"), for: UIControlState.normal)
        closeButton.setImage(UIImage(named: "close_highlighted"), for: UIControlState.highlighted)
        seeAllController.closeButton = closeButton
        seeAllController.closeLayout = closeLayout
        seeAllController.onItemSelected = { index in
            self.goToIndex(index)
        }
        present(seeAllController, animated: true, completion: nil)
    }

    public func goToIndex(_ index: Int) {
        guard currentIndex != index && index >= 0 && index < imageCount else { return }

        let imageViewController = self.imageControllerFactory.createImageViewController(index)
        let direction: UIPageViewControllerNavigationDirection = index > currentIndex ? .forward : .reverse

        // workaround to make UIPageViewController happy
        if direction == .forward {
            let previousVC = self.imageControllerFactory.createImageViewController(index - 1)
            setViewControllers([previousVC], direction: direction, animated: true, completion: { finished in
                DispatchQueue.main.async(execute: { [weak self] in
                    self?.setViewControllers([imageViewController], direction: direction, animated: false, completion: nil)
                })
            })
        } else {
            let nextVC = self.imageControllerFactory.createImageViewController(index + 1)
            setViewControllers([nextVC], direction: direction, animated: true, completion: { finished in
                DispatchQueue.main.async(execute: { [weak self] in
                    self?.setViewControllers([imageViewController], direction: direction, animated: false, completion: nil)
                })
            })
        }
    }

    func closeWithAnimation(_ completion: (() -> Void)?) {
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            
            self?.headerView?.alpha = 0.0
            self?.footerView?.alpha = 0.0
            self?.closeButton?.alpha = 0.0
            self?.seeAllButton?.alpha = 0.0
            
        }) { [weak self] done in
            
            if self?.currentIndex == self?.startIndex {
                
                self?.view.backgroundColor = UIColor.clear
                
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
    
    func postAnimationClose(_ completion: (() -> Void)?) {
        
        self.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: false) {
            
            self.applicationWindow!.windowLevel = UIWindowLevelNormal
            completion?()
        }
    }
    
    // MARK: - Image Controller Delegate
    
    func imageViewController(_ controller: ImageViewController, didSwipeToDismissWithDistanceToEdge distance: CGFloat) {
        
        self.view.backgroundColor = (distance == 0) ? backgroundColor : UIColor.clear
        
        if isDecorationViewsHidden == false {
            
            let alpha = 1 - distance * swipeToDismissFadeOutAccelerationFactor
            
            closeButton?.alpha = alpha
            seeAllButton?.alpha = alpha
            headerView?.alpha = alpha
            footerView?.alpha = alpha
        }
    }
    
    func imageViewControllerDidSingleTap(_ controller: ImageViewController) {
        
        let alpha: CGFloat = (isDecorationViewsHidden) ? 1 : 0
        
        isDecorationViewsHidden = !isDecorationViewsHidden
        
        UIView.animate(withDuration: toggleHeaderFooterAnimationDuration, animations: { [weak self] in
            
            self?.headerView?.alpha = alpha
            self?.footerView?.alpha = alpha
            self?.closeButton?.alpha = alpha
            self?.seeAllButton?.alpha = alpha
            })
    }
    
    func imageViewControllerDidAppear(_ controller: ImageViewController) {
        
        self.currentIndex = controller.index
        self.landedPageAtIndexCompletion?(self.currentIndex)
        self.headerView?.sizeToFit()
        self.footerView?.sizeToFit()
    }
}
