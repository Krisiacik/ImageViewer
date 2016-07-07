//
//  ImageViewer.swift
//  Money
//
//  Created by Kristian Angyal on 06/10/2015.
//  Copyright © 2015 Mail Online. All rights reserved.
//

import UIKit
import AVFoundation

/*
 
 Features:
 
 - double tap to toggle betweeen Aspect Fit & Aspect Fill zoom factor
 - manual pinch to zoom up to approx. 4x the size of full-sized image
 - rotation support
 - swipe to dismiss
 - initiation and completion blocks to support a case where the original image node should be hidden or unhidden alongside show and dismiss animations
 
 Usage:
 
 - Initialize ImageViewer, set optional initiation and completion blocks, and present by calling "presentImageViewer".
 
 How it works:
 
 - Gets presented modally via convenience UIViewControler extension, using custom modal presentation that is enforced internally.
 - Displays itself in full screen (nothing is visible at that point, but it's there, trust me...)
 - Makes a screenshot of the displaced view that can be any UIView (or subclass) really, but UIImageView is the most probable choice.
 - Puts this screenshot into a new UIImageView and matches its position and size to the displaced view.
 - Sets the target size and position for the UIImageView to aspectFit size and centered while kicking in the black overlay.
 - Animates the image view into the scroll view (that serves as zooming canvas) and reaches final position and size.
 - Immediately tries to get a full-sized version of the image from imageProvider.
 - If successful, replaces the screenshot in the image view with probably a higher-res image.
 - Gets dismissed either via Close button, or via "swipe up/down" gesture.
 - While being "closed", image is animated back to it's "original" position which is a rect that matches to the displaced view's position
 which overall gives us the illusion of the UI element returning to its original place.
 
 */

public final class ImageViewerController: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
    /// UI
    private var scrollView = UIScrollView()
    private var overlayView = UIView()
    private var closeButton = UIButton()
    private var imageView = UIImageView()
    private let displacedView: UIView
    private var applicationWindow: UIWindow? {
        return UIApplication.sharedApplication().delegate?.window?.flatMap { $0 }
    }
    
    /// LOCAL STATE
    private var parentViewFrameInOurCoordinateSystem = CGRectZero
    private var isAnimating = false
    private var shouldRotate = false
    private var isSwipingToDismiss = false
    private var dynamicTransparencyActive = false
    private let imageProvider: ImageProvider
    
    /// LOCAL CONFIG
    private let configuration: ImageViewerConfiguration
    private var initialCloseButtonOrigin = CGPointZero
    private var closeButtonSize = CGSize(width: 50, height: 50)
    private let closeButtonPadding         = 8.0
    private let showDuration               = 0.25
    private let dismissDuration            = 0.25
    private let showCloseButtonDuration    = 0.2
    private let hideCloseButtonDuration    = 0.05
    private let zoomDuration               = 0.2
    private let thresholdVelocity: CGFloat = 1000 // Based on UX experiments
    private let cutOffVelocity: CGFloat = 1000000 // we simply need some sufficiently large number, nobody can swipe faster than that
    /// TRANSITIONS
    private let presentTransition: ImageViewerPresentTransition
    private let dismissTransition: ImageViewerDismissTransition
    private let swipeToDismissTransition: ImageViewerSwipeToDismissTransition
    
    /// LIFE CYCLE BLOCKS
    
    /// Executed right before the image animation into its final position starts.
    public var showInitiationBlock: (Void -> Void)?
    /// Executed as the last step after all the show animations.
    public var showCompletionBlock: (Void -> Void)?
    /// Executed as the first step before the button's close action starts.
    public var closeButtonActionInitiationBlock: (Void -> Void)?
    /// Executed as the last step for close button's close action.
    public var closeButtonActionCompletionBlock: (Void -> Void)?
    /// Executed as the first step for swipe to dismiss action.
    public var swipeToDismissInitiationBlock: (Void -> Void)?
    /// Executed as the last step for swipe to dismiss action.
    public var swipeToDismissCompletionBlock: (Void -> Void)?
    /// Executed as the last step when the ImageViewer is dismissed (either via the close button, or swipe)
    public var dismissCompletionBlock: (Void -> Void)?
    
    /// INTERACTIONS
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    // MARK: - Deinit
    
    deinit {
        
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // MARK: - Initializers
    
    public init(imageProvider: ImageProvider, configuration: ImageViewerConfiguration, displacedView: UIView) {
        
        self.imageProvider = imageProvider
        self.configuration = configuration
        self.displacedView = displacedView
        
        self.presentTransition = ImageViewerPresentTransition(duration: showDuration)
        self.dismissTransition = ImageViewerDismissTransition(duration: dismissDuration)
        self.swipeToDismissTransition = ImageViewerSwipeToDismissTransition()
        
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .Custom
        extendedLayoutIncludesOpaqueBars = true
        
        overlayView.autoresizingMask = [.None]
        configureCloseButton()
        configureImageView()
        configureScrollView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    private func configureCloseButton() {
        
        let closeButtonAssets = configuration.closeButtonAssets
        
        closeButton.setImage(closeButtonAssets.normal, forState: UIControlState.Normal)
        closeButton.setImage(closeButtonAssets.highlighted, forState: UIControlState.Highlighted)
        closeButton.alpha = 0.0
        closeButton.addTarget(self, action: #selector(ImageViewerController.close(_:)), forControlEvents: .TouchUpInside)
    }
    
    private func configureGestureRecognizers() {
        
        doubleTapRecognizer.addTarget(self, action: #selector(ImageViewerController.scrollViewDidDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        panGestureRecognizer.addTarget(self, action: #selector(ImageViewerController.scrollViewDidPan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    private func configureImageView() {
        
        parentViewFrameInOurCoordinateSystem = CGRectIntegral(applicationWindow!.convertRect(displacedView.bounds, fromView: displacedView))
        
        imageView.frame = parentViewFrameInOurCoordinateSystem
        imageView.contentMode = .ScaleAspectFit
        imageView.image = screenshotFromView(displacedView)
    }
    
    private func configureScrollView() {
        
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.decelerationRate = 0.5
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = 1
        scrollView.delegate = self
    }
    
    func createViewHierarchy() {

        view.addSubview(overlayView)
        view.addSubview(imageView)
        view.addSubview(scrollView)
        view.addSubview(closeButton)
    }
    
    // MARK: - View Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        createViewHierarchy()
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        shouldRotate = true
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        let originX = -view.bounds.width
        let originY = -view.bounds.height
        
        let width = view.bounds.width * 4
        let height = view.bounds.height * 4
        
        overlayView.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: width, height: height))
        
        closeButton.frame = CGRect(origin: CGPoint(x: view.bounds.size.width - CGFloat(closeButtonPadding) - closeButtonSize.width, y: CGFloat(closeButtonPadding)), size: closeButtonSize)
        
        if shouldRotate {
            shouldRotate = false
            rotate()
        }
    }
    
    // MARK: - Transitioning Delegate
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return isSwipingToDismiss ? swipeToDismissTransition : dismissTransition
    }
    
    // MARK: - Animations
    
    func close(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func rotate() {
        guard UIDevice.currentDevice().orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        UIView.animateWithDuration(hideCloseButtonDuration, animations: { self.closeButton.alpha = 0.0 })
        
        let aspectFitSize = aspectFitContentSize(forBoundingSize: rotationAdjustedBounds().size, contentSize: displacedView.frame.size)
        UIView.animateWithDuration(showDuration, animations: { () -> Void in
            if isPortraitOnly() {
                self.view.transform = rotationTransform()
            }
            self.view.bounds = rotationAdjustedBounds()
            self.imageView.bounds = CGRect(origin: CGPointZero, size: aspectFitSize)
            self.imageView.center = self.scrollView.center
            self.scrollView.contentSize = self.imageView.bounds.size
            self.scrollView.setZoomScale(1.0, animated: false)
            
        }) { (finished) -> Void in
            if (finished) {
                self.isAnimating = false
                self.scrollView.maximumZoomScale = maximumZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: self.imageView.bounds.size)
                UIView.animateWithDuration(self.showCloseButtonDuration, animations: { self.closeButton.alpha = 1.0 })
            }
        }
    }
    
    func showAnimation(duration: NSTimeInterval, completion: ((Bool) -> Void)?) {
        
        guard isAnimating == false else { return }
        
        isAnimating = true
        showInitiationBlock?()
        displacedView.hidden = true
        
        overlayView.alpha = 0.0
        overlayView.backgroundColor = UIColor.blackColor()
        
        UIView.animateWithDuration(duration, animations: {
            self.view.transform = rotationTransform()
            self.overlayView.alpha = 1.0
            self.view.bounds = rotationAdjustedBounds()
            let aspectFitSize = aspectFitContentSize(forBoundingSize: rotationAdjustedBounds().size, contentSize: self.configuration.imageSize)
            self.imageView.bounds = CGRect(origin: CGPointZero, size: aspectFitSize)
            self.imageView.center = rotationAdjustedCenter(self.view)
            self.scrollView.contentSize = self.imageView.bounds.size
            
        }) { (finished) -> Void in
            completion?(finished)
            
            if finished {
                if isPortraitOnly() {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImageViewerController.rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
                }
                self.applicationWindow!.windowLevel = UIWindowLevelStatusBar + 1
                
                self.scrollView.addSubview(self.imageView)
                self.imageProvider.provideImage { [weak self] image in
                    self?.imageView.image = image
                }
                
                self.isAnimating = false
                self.scrollView.maximumZoomScale = maximumZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: self.imageView.bounds.size)
                UIView.animateWithDuration(self.showCloseButtonDuration, animations: { self.closeButton.alpha = 1.0 })
                self.configureGestureRecognizers()
                self.showCompletionBlock?()
                self.displacedView.hidden = false
            }
        }
    }
    
    func closeAnimation(duration: NSTimeInterval, completion: ((Bool) -> Void)?) {
        
        guard (self.isAnimating == false) else { return }
        isAnimating = true
        closeButtonActionInitiationBlock?()
        displacedView.hidden = true
        
        UIView.animateWithDuration(hideCloseButtonDuration, animations: { self.closeButton.alpha = 0.0 })
        
        UIView.animateWithDuration(duration, animations: {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            self.overlayView.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.view.transform = CGAffineTransformIdentity
            self.view.bounds = (self.applicationWindow?.bounds)!
            self.imageView.frame = CGRectIntegral(self.applicationWindow!.convertRect(self.displacedView.bounds, fromView: self.displacedView))
            
        }) { (finished) -> Void in
            completion?(finished)
            if finished {
                NSNotificationCenter.defaultCenter().removeObserver(self)
                self.applicationWindow!.windowLevel = UIWindowLevelNormal
                
                self.displacedView.hidden = false
                self.isAnimating = false
                
                self.closeButtonActionCompletionBlock?()
                self.dismissCompletionBlock?()
            }
        }
    }
    
    func swipeToDismissAnimation(withVerticalTouchPoint verticalTouchPoint: CGFloat,  targetOffset: CGFloat, verticalVelocity: CGFloat, completion: ((Bool) -> Void)?) {
        
        /// In units of "vertical velocity". for example if we have a vertical velocity of 50 units (which are points really) per second
        /// and the distance to travel is 175 units, then our spring velocity is 3.5. I.e. we will travel 3.5 units in 1 second.
        let springVelocity = fabs(verticalVelocity / (targetOffset - verticalTouchPoint))
        
        /// How much time it will take to travel the remaining distance given the above speed.
        let expectedDuration = NSTimeInterval( fabs(targetOffset - verticalTouchPoint) / fabs(verticalVelocity))
        
        UIView.animateWithDuration(expectedDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.scrollView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: false)
            
            }, completion: { (finished) -> Void in
                completion?(finished)
                
                if finished {
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                    self.view.transform = CGAffineTransformIdentity
                    self.view.bounds = (self.applicationWindow?.bounds)!
                    self.imageView.frame = self.parentViewFrameInOurCoordinateSystem
                    
                    self.overlayView.alpha = 0.0
                    self.closeButton.alpha = 0.0
                    self.isAnimating = false
                    self.isSwipingToDismiss = false
                    self.dynamicTransparencyActive = false
                    self.swipeToDismissCompletionBlock?()
                    self.dismissCompletionBlock?()
                }
        })
    }
    
    private func swipeToDismissCanceledAnimation() {
        
        UIView.animateWithDuration(zoomDuration, animations: { () -> Void in
            
            self.scrollView.setContentOffset(CGPointZero, animated: false)
            
            }, completion: { (finished) -> Void in
                
                if finished {
                    self.applicationWindow!.windowLevel = UIWindowLevelStatusBar + 1
                    
                    self.isAnimating = false
                    self.isSwipingToDismiss = false
                    self.dynamicTransparencyActive = false
                }
        })
    }
    
    // MARK: - Interaction Handling
    
    func scrollViewDidDoubleTap(recognizer: UITapGestureRecognizer) {
        
        let touchPoint = recognizer.locationOfTouch(0, inView: imageView)
        
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: imageView.bounds.size)
        
        if (scrollView.zoomScale == 1.0 || scrollView.zoomScale > aspectFillScale) {
            
            let zoomingRect = zoomRect(ForScrollView: scrollView, scale: aspectFillScale, center: touchPoint)
            
            UIView.animateWithDuration(zoomDuration, animations: {
                
                self.scrollView.zoomToRect(zoomingRect, animated: false)
            })
        }
        else  {
            UIView.animateWithDuration(zoomDuration, animations: {
                
                self.scrollView.setZoomScale(1.0, animated: false)
            })
        }
    }
    
    func scrollViewDidPan(recognizer: UIPanGestureRecognizer) {
        
        guard scrollView.zoomScale == scrollView.minimumZoomScale else { return }
        
        if isSwipingToDismiss == false {
            swipeToDismissInitiationBlock?()
            displacedView.hidden = false
        }
        isSwipingToDismiss = true
        dynamicTransparencyActive = true
        
        let targetOffsetToReachEdge =  (view.bounds.height / 2) + (imageView.bounds.height / 2)
        let lastTouchPoint = recognizer.translationInView(view)
        let verticalVelocity = recognizer.velocityInView(view).y
        
        switch recognizer.state {
            
        case .Began:
            applicationWindow!.windowLevel = UIWindowLevelNormal
            fallthrough
            
        case .Changed:
            scrollView.setContentOffset(CGPoint(x: 0, y: -lastTouchPoint.y), animated: false)
            
        case .Ended:
            handleSwipeToDismissEnded(verticalVelocity, lastTouchPoint: lastTouchPoint, targetOffset: targetOffsetToReachEdge)
            
        default:
            break
        }
    }
    
    func handleSwipeToDismissEnded(verticalVelocity: CGFloat, lastTouchPoint: CGPoint, targetOffset: CGFloat) {
        
        let velocity = abs(verticalVelocity)
        
        switch velocity {
            
        case 0 ..< thresholdVelocity:
            
            swipeToDismissCanceledAnimation()
            
        case thresholdVelocity ... cutOffVelocity:
        
            let offset = (verticalVelocity > 0) ? -targetOffset : targetOffset
            let touchPoint = (verticalVelocity > 0) ? -lastTouchPoint.y : lastTouchPoint.y
            
            swipeToDismissTransition.setParameters(touchPoint, targetOffset: offset, verticalVelocity: verticalVelocity)
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            
        default: break
        }
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        
        imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }
    
    // MARK: - KVO
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if (dynamicTransparencyActive == true && keyPath == "contentOffset") {
            
            let transparencyMultiplier: CGFloat = 10
            let velocityMultiplier: CGFloat = 300
            
            let distanceToEdge = (scrollView.bounds.height / 2) + (imageView.bounds.height / 2)
            
            overlayView.alpha = 1 - fabs(scrollView.contentOffset.y / distanceToEdge)
            closeButton.alpha = 1 - fabs(scrollView.contentOffset.y / distanceToEdge) * transparencyMultiplier
            
            let newY = CGFloat(closeButtonPadding) - abs(scrollView.contentOffset.y / distanceToEdge) * velocityMultiplier
            closeButton.frame = CGRect(origin: CGPoint(x: closeButton.frame.origin.x, y: newY), size: closeButton.frame.size)
        }
    }
}