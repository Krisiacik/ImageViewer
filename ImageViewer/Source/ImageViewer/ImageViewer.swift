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

- Initialize the VC, set optional initiation and completion blocks, and present by calling "show".

How it works:

- Attaches itself as a child viewcontroller to the root viewcontroller of the key window.
- displays itself in fullscreen (nothing is visible at that point, but it's there, trust me...)
- makes a screenshot of the parent node (can be any UIView subclass really, but a UIImageView is the most logical choice)
- puts this screnshot into an imageview matchig the position and size of the parent node.
- sets the target size and position for the imageview to aspect fit size and centered while kicking in the black overlay.
- animates this imageview into the scrollview (that will serve as zooming canvas) reaching final position and size.
- tries to get a full-sized version of the image, if succesful, replaces the screenhot with that image.
- dismiss either with close button, or "swipe up/down" gesture.
- if closed, image is animated back to it's original position in whatever controller that invoked this image viewer controller.

Features:

- double tap to toggle betweeen aspect fit & aspect fill zoom factor.
- manual pinch to zoom up to 4x the size of full-sized image
- rotation support
- swipe to dismiss
- initiation and completion blocks to support a case where the original image node should be hidden or unhidden alongside show and dismiss animations.

*/

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

public final class ImageViewer: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var overlayView: UIView!
    @IBOutlet private var closeButton: UIButton!
    
    private var imageView = UIImageView()
    
    private var applicationWindow: UIWindow? {
        if let window = UIApplication.sharedApplication().delegate?.window { return window }
        return nil
    }
    
    private var parentViewFrameInOurCoordinateSystem = CGRectZero
    private var isAnimating = false
    private var isSwipingToDismiss = false
    private var dynamicTransparencyActive = false
    private var initialCloseButtonFrame = CGRectZero

    private let showDuration               = 0.25
    private let dismissDuration            = 0.25
    private let showCloseButtonDuration    = 0.2
    private let hideCloseButtonDuration    = 0.05
    private let zoomDuration               = 0.2
    private let thresholdVelocity: CGFloat = 1000 // It works as a threshold.
    
    private let imageProvider: ImageProvider
    private let configuration: ImageViewerConfiguration
    private let displacedView: UIView
    
    public var showInitiationBlock: (Void -> Void)? //executed right before the image animation into its final position starts.
    public var showCompletionBlock: (Void -> Void)? //executed as the last step after all the show animations.
    public var closeButtonActionInitiationBlock: (Void -> Void)? //executed as the first step before the button's close action starts.
    public var closeButtonActionCompletionBlock: (Void -> Void)? //executed as the last step for close button's close action.
    public var swipeToDismissInitiationBlock: (Void -> Void)? //executed as the fist step for swipe to dismiss action.
    public var swipeToDismissCompletionBlock: (Void -> Void)? //executed as the last step for swipe to dismiss action.
    public var dismissCompletionBlock: (Void -> Void)? //executed as the last step when the ImageViewer is dismissed (either via the close button, or swipe)
    
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    // MARK: - Dealloc
    
    deinit {
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    // MARK: - Initializers
    
    public init(imageProvider: ImageProvider, configuration: ImageViewerConfiguration, displacedView: UIView) {
        
        self.imageProvider = imageProvider
        self.configuration = configuration
        self.displacedView = displacedView
        
        super.init(nibName: "ImageViewer", bundle: NSBundle.mainBundle())
        
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    private func configureCloseButton() {
        
        let closeButtonAssets = configuration.closeButtonAssets
        
        self.closeButton.setBackgroundImage(closeButtonAssets.normalAsset, forState: UIControlState.Normal)
        self.closeButton.setBackgroundImage(closeButtonAssets.highlightedAsset, forState: UIControlState.Highlighted)
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
        
        self.parentViewFrameInOurCoordinateSystem = CGRectIntegral(self.applicationWindow!.convertRect(self.displacedView.bounds, fromView: self.displacedView))
        
        self.imageView.frame = self.parentViewFrameInOurCoordinateSystem
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureCloseButton()
        self.configureImageView()
        self.configureScrollView()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.showAnimation()
    }
    
    // MARK: - Animations
    
    public func show() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // If we try to rootController.view.addSubview(self.view)
        // nothing will happen. That's why we are adding the view
        // as a subview of the self.applicationWindow
        guard let rootController = self.applicationWindow?.rootViewController else { return }
        
        self.view.frame = UIScreen.mainScreen().bounds
        self.applicationWindow!.addSubview(self.view)
        rootController.addChildViewController(self)
        self.didMoveToParentViewController(rootController)
        
        self.initialCloseButtonFrame = self.closeButton.frame
    }
    
    @IBAction private func close(sender: AnyObject) {
        
        self.closeAnimations()
    }
    
    func rotate() {
        
        guard UIDevice.currentDevice().orientation.isFlat == false &&
            self.isAnimating == false else { return }
        
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
    
    private func showAnimation() {
        
        guard self.isAnimating == false else { return }
        
        self.isAnimating = true
        self.showInitiationBlock?()
        self.displacedView.hidden = true
        
        let rotationTransform = CGAffineTransformMakeRotation(self.degreesToRadians(self.rotationAngleToMatchDeviceOrientation(UIDevice.currentDevice().orientation)))
        
        UIView.animateWithDuration(showDuration, animations: {
            
            self.overlayView.backgroundColor = UIColor.blackColor()
            self.view.transform = rotationTransform
            self.view.bounds = self.rotationAdjustedBounds()
            let aspectFitContentSize = self.aspectFitContentSize(forBoundingSize: self.rotationAdjustedBounds().size, contentSize: self.configuration.imageSize)
            self.imageView.bounds = CGRect(origin: CGPointZero, size: aspectFitContentSize)
            self.imageView.center = self.scrollView.center
            self.scrollView.contentSize = self.imageView.bounds.size
            
            }) { (finished) -> Void in
                
                if finished {
                    
                    self.applicationWindow!.windowLevel = UIWindowLevelStatusBar
                    
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
    
    private func closeAnimations() {
        
        guard (self.isAnimating == false) else { return }
        self.isAnimating = true
        self.closeButtonActionInitiationBlock?()
        self.displacedView.hidden = true
        
        UIView.animateWithDuration(self.hideCloseButtonDuration, animations: { self.closeButton.alpha = 0.0 })
        
        UIView.animateWithDuration(dismissDuration, animations: {
            
            self.applicationWindow!.windowLevel = UIWindowLevelNormal
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            self.overlayView.alpha = 0.0
            self.closeButton.alpha = 0.0
            self.view.transform = CGAffineTransformIdentity
            self.view.bounds = (self.applicationWindow?.bounds)!
            self.imageView.frame = self.parentViewFrameInOurCoordinateSystem
            
            }) { (finished) -> Void in
                if finished {
                    
                    self.displacedView.hidden = false
                    self.isAnimating = false
                    self.overlayView.alpha = 1.0
                    self.closeButton.alpha = 1.0
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                    self.closeButtonActionCompletionBlock?()
                    self.dismissCompletionBlock?()
                }
        }
    }
    
    private func swipeToDismissAnimation(withVerticalTouchPoint verticalTouchPoint: CGFloat,  targetOffset: CGFloat, verticalVelocity: CGFloat) {
        
        // in units of "vertical velocity". for example if we have a vertical velocity of 50 per second
        // and the distance to travel is 175, then our spring velocity is 3.5. I.e. we will travel 3.5 units in 1 second.
        let springVelocity = fabs(verticalVelocity / (targetOffset - verticalTouchPoint))
        
        //how much time it will take to travel the remaining distance given the above speed.
        let expectedDuration = NSTimeInterval( fabs(targetOffset - verticalTouchPoint) / fabs(verticalVelocity))
        
        UIView.animateWithDuration(expectedDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            
            self.scrollView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: false)
            
            }, completion: { (finished) -> Void in
                
                if finished {
                    
                    self.view.transform = CGAffineTransformIdentity
                    self.view.bounds = (self.applicationWindow?.bounds)!
                    self.imageView.frame = self.parentViewFrameInOurCoordinateSystem
                    
                    self.overlayView.alpha = 1.0
                    self.closeButton.alpha = 1.0
                    self.closeButton.frame = self.initialCloseButtonFrame
                    self.applicationWindow!.windowLevel = UIWindowLevelNormal
                    self.isAnimating = false
                    self.isSwipingToDismiss = false
                    self.dynamicTransparencyActive = false
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
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
                    
                    self.isAnimating = false
                    self.isSwipingToDismiss = false
                    self.dynamicTransparencyActive = false
                }
        })
    }
    
    // MARK: - Interaction Handling (UIScrollViewDelegate)
    
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
            
        case .Began, .Changed:
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -latestTouchPoint.y), animated: false)
            
        case .Ended:
            
            //in points per second
            let verticalVelocity = recognizer.velocityInView(self.view).y
            
            if verticalVelocity < -thresholdVelocity {
                self.swipeToDismissAnimation(withVerticalTouchPoint: latestTouchPoint.y, targetOffset: targetOffsetToReachTop, verticalVelocity: verticalVelocity)
            }
            else if verticalVelocity >= -thresholdVelocity && verticalVelocity <= thresholdVelocity {
                self.swipeToDismissCanceledAnimation()
            }
                
            else {
                self.swipeToDismissAnimation(withVerticalTouchPoint: latestTouchPoint.y, targetOffset: targetOffsetToReachBottom, verticalVelocity: verticalVelocity)
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
            
            let newY = self.initialCloseButtonFrame.origin.y - abs(self.scrollView.contentOffset.y / distanceToEdge) * velocityMultiplier
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
        
        guard let window = self.applicationWindow else { return CGRectZero }
        
        return (UIDevice.currentDevice().orientation.isLandscape) ? CGRect(origin: CGPointZero, size: window.bounds.size.inverted()): window.bounds
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
