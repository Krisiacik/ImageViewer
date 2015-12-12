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

- double tap to toggle betweeen aspect fit & aspect fill zoom factor.
- manual pinch to zoom up to approx. 4x the size of full-sized image/
- rotation support
- swipe to dismiss
- initiation and completion blocks to support a case where the original image node should be hidden or unhidden alongside show and dismiss animations.

Usage:

- Initialize the VC, set optional initiation and completion blocks, and present by calling "presentImageViewer".

How it works:

- gets presented modaly via convenience UIViewControler extension, using custom modal presentation that is enforced internally.
- displays itself in full screen (nothing is visible at that point, but it's there, trust me...)
- makes a screenshot of the displaced view that can be any UIView subclass really, but UIImageView is the most probable choice.
- puts this screnshot into a new UIImageView and matches its position and size to the displaced view.
- sets the target size and position for the UIImageView to aspectFit size and centered while kicking in the black overlay.
- animates the image view into the scroll view (that serves as zooming canvas) and reaches final position and size.
- immediately tries to get a full-sized version of the image from imageProvider. 
  If successful, replaces the screenshot in the image view with probably a higher-res image.
- gets dismissed either via Close button, or via "swipe up/down" gesture.
- while being "closed", image is animated back to it's "original" position which is a match to the displaced view's position
  that gives the illusion of a the UI element returning to its original place.

*/

extension UIViewController {
    
    func presentImageViewer(imageViewer: ImageViewer, completion: (Void -> Void)? = {}) {
        self.presentViewController(imageViewer, animated: true, completion: completion)
    }
}

public protocol ImageProvider {
    
    func provideImage(completion: UIImage? -> Void)
}

public struct CloseButtonAssets {
    
    public let normal: UIImage
    public let highlighted: UIImage?
    
    public init(normalAsset: UIImage, highlightedAsset: UIImage?) {
        
        self.normal = normalAsset
        self.highlighted = highlightedAsset
    }
}

public struct ImageViewerConfiguration {
    
    public let imageSize: CGSize
    public let closeButtonAssets: CloseButtonAssets
    
    public init(imageSize: CGSize, closeButtonAssets: CloseButtonAssets) {
        
        self.imageSize = imageSize
        self.closeButtonAssets = closeButtonAssets
    }
}

public final class ImageViewer: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
    //UI
    private let displacedView: UIView
    private var imageView = UIImageView()
    private var scrollView: UIScrollView!
    private var overlayView: UIView!
    private var closeButton: UIButton!
    private var applicationWindow: UIWindow {
        return UIApplication.sharedApplication().delegate!.window!!
    }
    
    //LOCAL STATE
    private var displacedViewFrameInLocalCoordinateSystem = CGRectZero
    private var isAnimating = false
    private var isSwipingToDismiss = false
    private var dynamicTransparencyActive = false
    private var shouldHideStatusBar = false
    
    private let imageProvider: ImageProvider
    
    //LOCAL CONFIG
    private let configuration: ImageViewerConfiguration
    private var initialCloseButtonOrigin = CGPointZero
    private var closeButtonSize = CGSize(width: 50, height: 50)
    private let closeButtonPadding         = 8.0
    private let showDuration               = 0.25
    private let dismissDuration            = 0.25
    private let showCloseButtonDuration    = 0.2
    private let hideCloseButtonDuration    = 0.05
    private let zoomDuration               = 0.2
    private let thresholdVelocity: CGFloat = 1000 // The swipe's speed must cross this threshold for the image to finish the animation instead of returning back to the center of screen. There is no special reason for the choice of nicely rounded value of 1000, it is just a coincidence it works well.

    //INTERACTIONS
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    //TRANSITIONS
    private let presentTransition: ImageViewerPresentTransition
    private let dismissTransition: ImageViewerDismissTransition
    private let swipeToDismissTransition: ImageViewerSwipeToDismissTransition
    
    //LIFE CYCLE BLOCKS
    public var showInitiationBlock: (Void -> Void)? //executed right before the image animation into its final position starts.
    public var showCompletionBlock: (Void -> Void)? //executed as the last step after all the show animations.
    public var closeButtonActionInitiationBlock: (Void -> Void)? //executed as the first step before the button's close action starts.
    public var closeButtonActionCompletionBlock: (Void -> Void)? //executed as the last step for close button's close action.
    public var swipeToDismissInitiationBlock: (Void -> Void)? //executed as the fist step for swipe to dismiss action.
    public var swipeToDismissCompletionBlock: (Void -> Void)? //executed as the last step for swipe to dismiss action.
    public var dismissCompletionBlock: (Void -> Void)? //executed as the last step when the ImageViewer is dismissed (either via the close button, or swipe)

    
    // MARK: - Deinitializers
    
    deinit {
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // MARK: - Initializers
    
    public init(imageProvider: ImageProvider, configuration: ImageViewerConfiguration, displacedView: UIView) {
        
        self.imageProvider = imageProvider
        self.configuration = configuration
        self.displacedView = displacedView
        self.presentTransition = ImageViewerPresentTransition(duration: self.showDuration)
        self.dismissTransition = ImageViewerDismissTransition(duration: self.dismissDuration)
        self.swipeToDismissTransition = ImageViewerSwipeToDismissTransition()
        super.init(nibName: nil, bundle: nil)

        self.transitioningDelegate = self
        self.modalPresentationStyle = .Custom
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    private func configureCloseButton() {
        
        let closeButtonAssets = configuration.closeButtonAssets
        
        self.closeButton.setBackgroundImage(closeButtonAssets.normal, forState: UIControlState.Normal)
        self.closeButton.setBackgroundImage(closeButtonAssets.highlighted, forState: UIControlState.Highlighted)
        self.closeButton.alpha = 0.0
    }
    
    private func configureGestureRecognizers() {
        
        self.doubleTapRecognizer.addTarget(self, action: "scrollViewDidDoubleTap:")
        self.doubleTapRecognizer.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(doubleTapRecognizer)
        self.panGestureRecognizer.addTarget(self, action: "scrollViewDidPan:")
        self.view.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    private func configureImageView() {
        
        self.displacedViewFrameInLocalCoordinateSystem = CGRectIntegral(self.applicationWindow.convertRect(self.displacedView.bounds, fromView: self.displacedView))
        
        self.imageView.frame = self.displacedViewFrameInLocalCoordinateSystem
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(self.imageView)
        
        UIGraphicsBeginImageContextWithOptions(self.displacedView.bounds.size, true, UIScreen.mainScreen().scale)
        self.displacedView.drawViewHierarchyInRect(self.displacedView.bounds, afterScreenUpdates: false)
        self.imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func configureScrollView() {
        
        self.scrollView.decelerationRate = 0.5
        self.scrollView.contentInset = UIEdgeInsetsZero
        self.scrollView.contentOffset = CGPointZero
        self.scrollView.contentSize = self.imageView.frame.size
        self.scrollView.minimumZoomScale = 1
        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    // MARK: - View Lifecycle
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.scrollView.frame = self.view.bounds
        
        let originX = -self.view.bounds.width
        let originY = -self.view.bounds.height

        let width = self.view.bounds.width * 4
        let height = self.view.bounds.height * 4
        
        self.overlayView.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: width, height: height))
        
        self.closeButton.frame = CGRect(origin: CGPoint(x: self.view.bounds.size.width - CGFloat(closeButtonPadding) - closeButtonSize.width, y: CGFloat(closeButtonPadding)), size: closeButtonSize)
    }
    
    public override func loadView() {
        super.loadView()
        
        self.scrollView = UIScrollView(frame: CGRectZero)
        self.overlayView = UIView(frame: CGRectZero)
        self.closeButton = UIButton(frame: CGRectZero)

        self.scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.overlayView.autoresizingMask = [.None]

        self.view.addSubview(overlayView)
        self.view.addSubview(scrollView)
        self.view.addSubview(closeButton)
        
        self.scrollView.delegate = self
        self.closeButton.addTarget(self, action: "close:", forControlEvents: .TouchUpInside)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCloseButton()
        self.configureImageView()
        self.configureScrollView()
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return shouldHideStatusBar
    }
    
    private func hideStatusBar(hidden: Bool) {
        shouldHideStatusBar = hidden
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Transitioning Delegate
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return isSwipingToDismiss ? swipeToDismissTransition : dismissTransition
    }
    
    // MARK: - Animations
    
    private func close(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func rotate() {
        
        guard UIDevice.currentDevice().orientation.isFlat == false && self.isAnimating == false else { return }
        
        self.isAnimating = true
        
        UIView.animateWithDuration(hideCloseButtonDuration, animations: { self.closeButton.alpha = 0.0 })
        
        let rotationTransform = CGAffineTransformMakeRotation(self.degreesToRadians(self.rotationAngleToMatchDeviceOrientation(UIDevice.currentDevice().orientation)))
        let aspectFitContentSize = self.aspectFitContentSize(forBoundingSize: self.rotationAdjustedBounds().size, contentSize: self.displacedView.frame.size)
        
        UIView.animateWithDuration(showDuration, animations: { () -> Void in
            
            self.view.transform = rotationTransform
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
        
        guard self.isAnimating == false else { return }
        
        self.isAnimating = true
        self.showInitiationBlock?()
        self.displacedView.hidden = true
        
        let rotationTransform = CGAffineTransformMakeRotation(self.degreesToRadians(self.rotationAngleToMatchDeviceOrientation(UIDevice.currentDevice().orientation)))
        
        self.overlayView.alpha = 0.0
        self.overlayView.backgroundColor = UIColor.blackColor()
        
        UIView.animateWithDuration(duration, animations: {
            
            self.overlayView.alpha = 1.0
            self.view.transform = rotationTransform
            self.view.bounds = self.rotationAdjustedBounds()
            let aspectFitContentSize = self.aspectFitContentSize(forBoundingSize: self.rotationAdjustedBounds().size, contentSize: self.configuration.imageSize)
            self.imageView.bounds = CGRect(origin: CGPointZero, size: aspectFitContentSize)
            self.imageView.center = self.rotationAdjustedCenter()
            self.scrollView.contentSize = self.imageView.bounds.size
            
            }) { (finished) -> Void in
                completion?(finished)
                
                if finished {
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
                    self.hideStatusBar(true)

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
        self.isAnimating = true
        self.closeButtonActionInitiationBlock?()
        self.displacedView.hidden = true
        
        UIView.animateWithDuration(self.hideCloseButtonDuration, animations: { self.closeButton.alpha = 0.0 })
        
        UIView.animateWithDuration(duration, animations: {
            
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            self.overlayView.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.view.transform = CGAffineTransformIdentity
            self.view.bounds = self.applicationWindow.bounds
            self.imageView.frame = self.displacedViewFrameInLocalCoordinateSystem
            
            }) { (finished) -> Void in
                completion?(finished)
                
                if finished {
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                    self.hideStatusBar(false)

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
                    self.view.bounds = self.applicationWindow.bounds
                    self.imageView.frame = self.displacedViewFrameInLocalCoordinateSystem
                    
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
                    self.hideStatusBar(true)
                    
                    self.isAnimating = false
                    self.isSwipingToDismiss = false
                    self.dynamicTransparencyActive = false
                }
        })
    }
    
    // MARK: - Interaction Handling
    
    func scrollViewDidDoubleTap(recognizer: UITapGestureRecognizer) {
        
        let touchPoint = recognizer.locationOfTouch(0, inView: self.imageView)
        let aspectFillScale = self.aspectFillZoomScale(forBoundingSize: self.rotationAdjustedBounds().size, contentSize: self.imageView.bounds.size)
        
        if (self.scrollView.zoomScale == 1.0 || self.scrollView.zoomScale > aspectFillScale) {
            
            let zoomRect = self.zoomRect(ForScrollView: self.scrollView, scale: aspectFillScale, center: touchPoint)
            
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
        
        guard self.scrollView.zoomScale == self.scrollView.minimumZoomScale else { return }
        
        if self.isSwipingToDismiss == false {
            self.swipeToDismissInitiationBlock?()
            self.displacedView.hidden = false
        }
        self.isSwipingToDismiss = true
        self.dynamicTransparencyActive = true
        
        let targetOffsetToReachTop =  (self.view.bounds.height / 2) + (self.imageView.bounds.height / 2)
        let targetOffsetToReachBottom =  -targetOffsetToReachTop
        let latestTouchPoint = recognizer.translationInView(self.view)
        
        switch recognizer.state {
            
        case .Began:
            self.hideStatusBar(false)
            fallthrough
        case .Changed:
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -latestTouchPoint.y), animated: false)
            
        case .Ended:
            
            //in points per second
            let verticalVelocity = recognizer.velocityInView(self.view).y
            
            if verticalVelocity < -thresholdVelocity {
                self.swipeToDismissTransition.setParameters(latestTouchPoint.y, targetOffset: targetOffsetToReachTop, verticalVelocity: verticalVelocity)
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            else if verticalVelocity >= -thresholdVelocity && verticalVelocity <= thresholdVelocity {
                self.swipeToDismissCanceledAnimation()
            }
            else {
                self.swipeToDismissTransition.setParameters(latestTouchPoint.y, targetOffset: targetOffsetToReachBottom, verticalVelocity: verticalVelocity)
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
            
        default:
            break
        }
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        
        self.imageView.center = self.contentCenter(forBoundingSize: self.scrollView.bounds.size, contentSize: self.scrollView.contentSize)
    }
    
    // MARK: - KVO
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if (self.dynamicTransparencyActive == true && keyPath == "contentOffset") {
            
            let transparencyMultiplier: CGFloat = 10
            let velocityMultiplier: CGFloat = 300
            
            let distanceToEdge = (self.scrollView.bounds.height / 2) + (self.imageView.bounds.height / 2)
            
            self.overlayView.alpha = 1 - fabs(self.scrollView.contentOffset.y / distanceToEdge)
            
            self.closeButton.alpha = 1 - fabs(self.scrollView.contentOffset.y / distanceToEdge) * transparencyMultiplier
            
            
            
            let newY = CGFloat(closeButtonPadding) - abs(self.scrollView.contentOffset.y / distanceToEdge) * velocityMultiplier
            self.closeButton.frame = CGRect(origin: CGPoint(x: self.closeButton.frame.origin.x, y: newY), size: self.closeButton.frame.size)
        }
    }
    
    // MARK: - Utilitity
    
    private func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {
        
        // When the zoom scale changes i.e. the image is zoomed in our out, the hypothetical center
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
        
        return (UIDevice.currentDevice().orientation.isLandscape) ? CGRect(origin: CGPointZero, size: self.applicationWindow.bounds.size.inverted()): self.applicationWindow.bounds
    }
    
    private func rotationAdjustedCenter() -> CGPoint {
        return (UIDevice.currentDevice().orientation.isLandscape) ? self.view.center.inverted() : self.view.center
    }
    
    private func rotationAngleToMatchDeviceOrientation(orientation: UIDeviceOrientation) -> CGFloat {
        
        var desiredRotationAngle: CGFloat = 0
        
        switch orientation {
            
        case .Portrait,           .FaceUp:      desiredRotationAngle = 0
        case .PortraitUpsideDown, .FaceDown:    desiredRotationAngle = -180
        case .LandscapeLeft:                    desiredRotationAngle = 90
        case .LandscapeRight:                   desiredRotationAngle = -90
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
