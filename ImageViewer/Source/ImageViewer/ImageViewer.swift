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

Usage:

- Initialize the VC, set optional initiation and completion blocks, and present by calling "presentImageViewer".

How it works:

- Attaches itself as a child viewcontroller to the root viewcontroller of the key window.
- displays itself in fullscreen (nothing is visible at that point, but it's there, trust me...)
- makes a screenshot of the parent node (can be any UIView subclass really, but a UIImageView is the most logical choice)
- puts this screenshot into an imageview matching the position and size of the parent node.
- sets the target size and position for the imageview to aspect fit size and centered while kicking in the black overlay.
- animates this imageview into the scrollview (that will serve as zooming canvas) reaching final position and size.
- tries to get a full-sized version of the image, if successful, replaces the screenshot with that image.
- dismiss either with close button, or "swipe up/down" gesture.
- if closed, image is animated back to it's original position in whatever controller that invoked this image viewer controller.

Features:

- double tap to toggle between aspect fit & aspect fill zoom factor.
- manual pinch to zoom up to 4x the size of full-sized image
- rotation support
- swipe to dismiss
- initiation and completion blocks to support a case where the original image node should be hidden or unhidden alongside show and dismiss animations.

*/

public extension UIViewController {
    
    public func presentImageViewer(imageViewer: ImageViewer, completion: (Void -> Void)? = {}) {
        presentViewController(imageViewer, animated: true, completion: completion)
    }
}

public protocol ImageProvider {
    
    func provideImage(completion: UIImage? -> Void)
}

public struct ButtonStateAssets {
    
    public let normalAsset: UIImage
    public let highlightedAsset: UIImage?
    
    public init(normalAsset: UIImage, highlightedAsset: UIImage?) {
        
        self.normalAsset = normalAsset
        self.highlightedAsset = highlightedAsset
    }
}

public struct ImageViewerConfiguration {
    
    public let imageSize: CGSize
    public let closeButtonAssets: ButtonStateAssets
    
    public init(imageSize: CGSize, closeButtonAssets: ButtonStateAssets) {
        
        self.imageSize = imageSize
        self.closeButtonAssets = closeButtonAssets
    }
}

public final class ImageViewer: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
    private var scrollView: UIScrollView!
    private var overlayView: UIView!
    private var closeButton: UIButton!
    
    private var imageView = UIImageView()
    
    private var applicationWindow: UIWindow? {
        if let window = UIApplication.sharedApplication().delegate?.window { return window }
        return nil
    }
    
    private var parentViewFrameInOurCoordinateSystem = CGRectZero
    private var isAnimating = false
    private var shouldRotate = false
    private var isSwipingToDismiss = false
    private var dynamicTransparencyActive = false
    private var initialCloseButtonOrigin = CGPointZero
    private var closeButtonSize = CGSize(width: 50, height: 50)
    private var isPortraitOnly = false

    private let closeButtonPadding         = 8.0
    private let showDuration               = 0.25
    private let dismissDuration            = 0.25
    private let showCloseButtonDuration    = 0.2
    private let hideCloseButtonDuration    = 0.05
    private let zoomDuration               = 0.2
    private let thresholdVelocity: CGFloat = 1000 // It works as a threshold.
    
    private let imageProvider: ImageProvider
    private let configuration: ImageViewerConfiguration
    private let displacedView: UIView
    
    private let presentTransition: ImageViewerPresentTransition
    private let dismissTransition: ImageViewerDismissTransition
    private let swipeToDismissTransition: ImageViewerSwipeToDismissTransition
    
    public var showInitiationBlock: (Void -> Void)? //executed right before the image animation into its final position starts.
    public var showCompletionBlock: (Void -> Void)? //executed as the last step after all the show animations.
    public var closeButtonActionInitiationBlock: (Void -> Void)? //executed as the first step before the button's close action starts.
    public var closeButtonActionCompletionBlock: (Void -> Void)? //executed as the last step for close button's close action.
    public var swipeToDismissInitiationBlock: (Void -> Void)? //executed as the first step for swipe to dismiss action.
    public var swipeToDismissCompletionBlock: (Void -> Void)? //executed as the last step for swipe to dismiss action.
    public var dismissCompletionBlock: (Void -> Void)? //executed as the last step when the ImageViewer is dismissed (either via the close button, or swipe)
    
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    // MARK: - Dealloc
    
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
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    private func configureCloseButton() {
        
        let closeButtonAssets = configuration.closeButtonAssets
        
        closeButton.setImage(closeButtonAssets.normalAsset, forState: UIControlState.Normal)
        closeButton.setImage(closeButtonAssets.highlightedAsset, forState: UIControlState.Highlighted)
        closeButton.alpha = 0.0
    }
    
    private func configureGestureRecognizers() {
        
        doubleTapRecognizer.addTarget(self, action: "scrollViewDidDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        panGestureRecognizer.addTarget(self, action: "scrollViewDidPan:")
        view.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    private func configureImageView() {
        
        parentViewFrameInOurCoordinateSystem = CGRectIntegral(applicationWindow!.convertRect(displacedView.bounds, fromView: displacedView))
        
        imageView.frame = parentViewFrameInOurCoordinateSystem
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(imageView)
        
        UIGraphicsBeginImageContextWithOptions(displacedView.bounds.size, true, UIScreen.mainScreen().scale)
        displacedView.drawViewHierarchyInRect(displacedView.bounds, afterScreenUpdates: false)
        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func configureScrollView() {
        
        scrollView.decelerationRate = 0.5
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = imageView.frame.size
        scrollView.minimumZoomScale = 1
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    // MARK: - View Lifecycle
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
    
    public override func loadView() {
        super.loadView()
        
        scrollView = UIScrollView(frame: CGRectZero)
        overlayView = UIView(frame: CGRectZero)
        closeButton = UIButton(frame: CGRectZero)

        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        overlayView.autoresizingMask = [.None]

        view.addSubview(overlayView)
        view.addSubview(scrollView)
        view.addSubview(closeButton)
        
        scrollView.delegate = self
        closeButton.addTarget(self, action: "close:", forControlEvents: .TouchUpInside)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        isPortraitOnly = presentingViewController!.supportedInterfaceOrientations() == .Portrait ||
            UIApplication.sharedApplication().supportedInterfaceOrientationsForWindow(nil) == .Portrait
        
        configureCloseButton()
        configureImageView()
        configureScrollView()
    }

    // MARK: UIViewControllerTransitioningDelegate
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return isSwipingToDismiss ? swipeToDismissTransition : dismissTransition
    }
    
    // MARK: - Animations
    
    @IBAction private func close(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func rotate() {
        guard UIDevice.currentDevice().orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        UIView.animateWithDuration(hideCloseButtonDuration, animations: { self.closeButton.alpha = 0.0 })
        
        let aspectFitContentSize = self.aspectFitContentSize(forBoundingSize: rotationAdjustedBounds().size, contentSize: displacedView.frame.size)
        UIView.animateWithDuration(showDuration, animations: { () -> Void in
            if self.isPortraitOnly {
                self.view.transform = self.rotationTransform()
            }
            self.view.bounds = self.rotationAdjustedBounds()
            self.imageView.bounds = CGRect(origin: CGPointZero, size: aspectFitContentSize)
            self.imageView.center = self.scrollView.center
            self.scrollView.contentSize = self.imageView.bounds.size
            self.scrollView.setZoomScale(1.0, animated: false)
            
            }) { (finished) -> Void in
                if (finished) {
                    self.isAnimating = false
                    self.scrollView.maximumZoomScale = self.maximumZoomScale(forBoundingSize: self.rotationAdjustedBounds().size, contentSize: self.imageView.bounds.size)
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
            self.view.transform = self.rotationTransform()
            self.overlayView.alpha = 1.0
            self.view.bounds = self.rotationAdjustedBounds()
            let aspectFitContentSize = self.aspectFitContentSize(forBoundingSize: self.rotationAdjustedBounds().size, contentSize: self.configuration.imageSize)
            self.imageView.bounds = CGRect(origin: CGPointZero, size: aspectFitContentSize)
            self.imageView.center = self.rotationAdjustedCenter()
            self.scrollView.contentSize = self.imageView.bounds.size
            
            }) { (finished) -> Void in
                completion?(finished)
                
                if finished {
                    if self.isPortraitOnly {
                        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
                    }
                    self.applicationWindow!.windowLevel = UIWindowLevelStatusBar + 1

                    self.scrollView.addSubview(self.imageView)
                    self.imageProvider.provideImage { [weak self] image in
                        self?.imageView.image = image
                    }
                    
                    self.isAnimating = false
                    self.scrollView.maximumZoomScale = self.maximumZoomScale(forBoundingSize: self.rotationAdjustedBounds().size, contentSize: self.imageView.bounds.size)
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
        
        // in units of "vertical velocity". for example if we have a vertical velocity of 50 per second
        // and the distance to travel is 175, then our spring velocity is 3.5. I.e. we will travel 3.5 units in 1 second.
        let springVelocity = fabs(verticalVelocity / (targetOffset - verticalTouchPoint))
        
        //how much time it will take to travel the remaining distance given the above speed.
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
    
    // MARK: - Interaction Handling (UIScrollViewDelegate)
    
    func scrollViewDidDoubleTap(recognizer: UITapGestureRecognizer) {
        
        let touchPoint = recognizer.locationOfTouch(0, inView: imageView)
        
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: imageView.bounds.size)
        
        if (scrollView.zoomScale == 1.0 || scrollView.zoomScale > aspectFillScale) {
            
            let zoomRect = self.zoomRect(ForScrollView: scrollView, scale: aspectFillScale, center: touchPoint)
            
            UIView.animateWithDuration(zoomDuration, animations: {
                
                self.scrollView.zoomToRect(zoomRect, animated: false)
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
        
        let targetOffsetToReachTop =  (view.bounds.height / 2) + (imageView.bounds.height / 2)
        let targetOffsetToReachBottom =  -targetOffsetToReachTop
        let latestTouchPoint = recognizer.translationInView(view)
        
        switch recognizer.state {
            
        case .Began:
            applicationWindow!.windowLevel = UIWindowLevelNormal
            fallthrough
        case .Changed:
            scrollView.setContentOffset(CGPoint(x: 0, y: -latestTouchPoint.y), animated: false)
            
        case .Ended:
            
            //in points per second
            let verticalVelocity = recognizer.velocityInView(view).y
            
            if verticalVelocity < -thresholdVelocity {
                swipeToDismissTransition.setParameters(latestTouchPoint.y, targetOffset: targetOffsetToReachTop, verticalVelocity: verticalVelocity)
                presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            else if verticalVelocity >= -thresholdVelocity && verticalVelocity <= thresholdVelocity {
                swipeToDismissCanceledAnimation()
            }
            else {
                swipeToDismissTransition.setParameters(latestTouchPoint.y, targetOffset: targetOffsetToReachBottom, verticalVelocity: verticalVelocity)
                presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            
        default:
            break
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
    
    // MARK: - Utility
    
    private func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {
        
        // When the zoom scale changes i.e. the image is zoomed in or out, the hypothetical center
        // of content view changes too. But the default Apple implementation is keeping the last center
        // value which doesn't make much sense. If the image ratio is not matching the screen 
        // ratio, there will be some empty space horizontaly or verticaly. This needs to be calculated
        // so that we can get the correct new center value. When these are added, edges of contentView
        // are aligned in realtime and always aligned with corners of scrollview.
        
        let horizontalOffest = (boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5): 0.0
        let verticalOffset = (boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5): 0.0
        
        return CGPoint(x: contentSize.width * 0.5 + horizontalOffest,  y: contentSize.height * 0.5 + verticalOffset)
    }
    
    private func aspectFillZoomScale(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGFloat {
        
        let aspectFitContentSize = self.aspectFitContentSize(forBoundingSize: boundingSize, contentSize: contentSize)
        return (boundingSize.width == aspectFitContentSize.width) ? (boundingSize.height / aspectFitContentSize.height): (boundingSize.width / aspectFitContentSize.width)
    }
    
    private func aspectFitContentSize(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGSize {
        
        return AVMakeRectWithAspectRatioInsideRect(contentSize, CGRect(origin: CGPointZero, size: boundingSize)).size
    }
    
    private func maximumZoomScale(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGFloat {
        
        //we want to allow the image to always cover 4x the area of screen
        return min(boundingSize.width, boundingSize.height) / min(contentSize.width, contentSize.height) * 4
    }
    
    private func rotationAdjustedBounds() -> CGRect {
        guard let window = applicationWindow else { return CGRectZero }
        guard isPortraitOnly else {
            return window.bounds
        }
        
        return (UIDevice.currentDevice().orientation.isLandscape) ? CGRect(origin: CGPointZero, size: window.bounds.size.inverted()): window.bounds
    }
    
    private func rotationAdjustedCenter() -> CGPoint {
        guard isPortraitOnly else {
            return view.center
        }
        
        return (UIDevice.currentDevice().orientation.isLandscape) ? view.center.inverted() : view.center
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
    
    private func zoomRect(ForScrollView scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
        
        let width = scrollView.frame.size.width  / scale
        let height = scrollView.frame.size.height / scale
        let originX = center.x - (width / 2.0)
        let originY = center.y - (height / 2.0)
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}
