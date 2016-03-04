//
//  ImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public class ImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    
    //UI
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    private let blackOverlayView = UIView()
    private let containerView = UIView()
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
    var applicationWindow: UIWindow? {
        return UIApplication.sharedApplication().delegate?.window?.flatMap { $0 }
    }
    
    //MODEL & STATE
    let imageViewModel: GalleryViewModel
    weak private var fadeInHandler: ImageFadeInHandler?
    let index: Int
    let showDisplacedImage: Bool
    private var isPortraitOnly = false
    private var isSwipingToDismiss = false
    private var isAnimating = false
    private var dynamicTransparencyActive = false
    private let zoomDuration = 0.2
    
    //LOCAL CONFIG
    private let thresholdVelocity: CGFloat = 1000 // It works as a threshold.
    private let hideCloseButtonDuration    = 0.05
    
    //INTERACTIONS
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    //TRANSITIONS
    private var swipeToDissmissTransition: GallerySwipeToDismissTransition!
    
    
    //LIFE CYCLE BLOCKS
    public var showInitiationBlock: (Void -> Void)? //executed right before the image animation into its final position starts.
    public var showCompletionBlock: (Void -> Void)? //executed as the last step after all the show animations.
    public var closeButtonActionInitiationBlock: (Void -> Void)? //executed as the first step before the button's close action starts.
    public var closeButtonActionCompletionBlock: (Void -> Void)? //executed as the last step for close button's close action.
    public var swipeToDismissInitiationBlock: (Void -> Void)? //executed as the first step for swipe to dismiss action.
    public var swipeToDismissCompletionBlock: (Void -> Void)? //executed as the last step for swipe to dismiss action.
    public var dismissCompletionBlock: (Void -> Void)? //executed as the last step when the ImageViewer is dismissed (either via the close button, or swipe)
    
    init(imageViewModel: GalleryViewModel, imageIndex: Int, showDisplacedImage: Bool, fadeInHandler: ImageFadeInHandler?) {
        
        self.imageViewModel = imageViewModel
        self.index = imageIndex
        self.showDisplacedImage = showDisplacedImage
        self.fadeInHandler = fadeInHandler
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = UIColor.clearColor()
        blackOverlayView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(blackOverlayView)
        self.modalPresentationStyle = .Custom
        
        activityIndicatorView.startAnimating()
        self.scrollView.addSubview(activityIndicatorView)
        
        configureImageView()
        configureScrollView()
        configureGestureRecognizers()
        createViewHierarchy()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    func configureImageView() {
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        if showDisplacedImage {
            updateImageAndContentSize(imageViewModel.displacedImage)
        }
        
        imageViewModel.fetchImage(self.index) { [weak self] image in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let fullSizedImage = image {
                    self?.updateImageAndContentSize(fullSizedImage)
                }
            }
        }
    }
    
    func updateImageAndContentSize(image: UIImage) {
        
        if imageView.image == nil {
            
            scrollView.zoomScale = 1
            let aspectFitSize = aspectFitContentSize(forBoundingSize: UIScreen.mainScreen().bounds.size, contentSize: image.size)
            imageView.frame.size = aspectFitSize
            self.scrollView.contentSize = aspectFitSize
            imageView.center = scrollView.boundsCenter
        }
        
        if let handler = fadeInHandler where handler.wasPresented(self.index) == false {
            
            if self.index != self.imageViewModel.startIndex {
                
                activityIndicatorView.stopAnimating()
                
                UIView.transitionWithView(self.scrollView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                    
                    self.imageView.image = image
                    
                    }, completion: { finished in
                        
                        handler.imagePresentedAtIndex(self.index)
                })
                
                return
            }
        }
        
        self.imageView.image = image
        fadeInHandler?.imagePresentedAtIndex(self.index)
    }
    
    func configureScrollView() {
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.decelerationRate = 0.5
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSize(width: 100, height: 100) //FIX THIS
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
        
    }
    
    func configureGestureRecognizers() {
        
        doubleTapRecognizer.addTarget(self, action: "scrollViewDidDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        panGestureRecognizer.addTarget(self, action: "scrollViewDidPan:")
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func createViewHierarchy() {
        
        scrollView.addSubview(imageView)
        self.view.addSubview(scrollView)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = self.view.bounds
        blackOverlayView.frame = self.view.bounds
        containerView.frame = self.view.bounds
        imageView.center = scrollView.boundsCenter
        activityIndicatorView.center = scrollView.boundsCenter
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
    }

    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        print("WILL APPEAR \(self.index)")
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        rotate(toBoundingSize: size, transitionCoordinator: coordinator)
    }
    
    func rotate(toBoundingSize boundingSize: CGSize, transitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ [weak self] transitionContext in
            
            if let imageView = self?.imageView, scrollView = self?.scrollView {
                
                imageView.bounds.size = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: imageView.bounds.size)
                scrollView.zoomScale = 1
            }
            }, completion: nil)
    }
    
    func scrollViewDidDoubleTap(recognizer: UITapGestureRecognizer) {
        
        let touchPoint = recognizer.locationOfTouch(0, inView: imageView)
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: scrollView.bounds.size, contentSize: imageView.bounds.size)
        
        if (scrollView.zoomScale == 1.0 || scrollView.zoomScale > aspectFillScale) {
            
            let zoomRectangle = zoomRect(ForScrollView: scrollView, scale: aspectFillScale, center: touchPoint)
            
            UIView.animateWithDuration(zoomDuration, animations: {
                self.scrollView.zoomToRect(zoomRectangle, animated: false)
            })
        }
        else  {
            UIView.animateWithDuration(zoomDuration, animations: {
                self.scrollView.setZoomScale(1.0, animated: false)
            })
        }
    }
    
    public func scrollViewDidZoom(scrollView: UIScrollView) {
        
        imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }
    
    func scrollViewDidPan(recognizer: UIPanGestureRecognizer) {

        swipeToDissmissTransition = GallerySwipeToDismissTransition(presentingViewController: self.presentingViewController, scrollView: self.scrollView)
        
        self.parentViewController?.view.backgroundColor = UIColor.clearColor()


        guard scrollView.zoomScale == scrollView.minimumZoomScale else { return }
        
        if isSwipingToDismiss == false {
            swipeToDismissInitiationBlock?()
            imageViewModel.displacedView.hidden = false
        }
        isSwipingToDismiss = true
        dynamicTransparencyActive = true
        
        let targetOffsetToReachTop =  (view.bounds.height / 2) + (imageView.bounds.height / 2)
        let targetOffsetToReachBottom =  -targetOffsetToReachTop
        let latestTouchPoint = recognizer.translationInView(view)
        
        switch recognizer.state {
            
        case .Began:
            
            applicationWindow!.windowLevel = UIWindowLevelNormal
            
        case .Changed:

            swipeToDissmissTransition.updateInteractiveTransition(-latestTouchPoint.y)
            
        case .Ended:
            
            let presentingViewController = self.presentingViewController
            
            //in points per second
            let finalVerticalVelocity = recognizer.velocityInView(view).y
            
            if finalVerticalVelocity < -thresholdVelocity {
                
                swipeToDissmissTransition.finishInteractiveTransition(latestTouchPoint.y, targetOffset: targetOffsetToReachTop, escapeVelocity: finalVerticalVelocity) {
                
                    presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
                }
            }
            else if finalVerticalVelocity >= -thresholdVelocity && finalVerticalVelocity <= thresholdVelocity {
                
                swipeToDissmissTransition.cancelTransition()
                self.parentViewController?.view.backgroundColor = UIColor.blackColor()

            }
            else {
                swipeToDissmissTransition.finishInteractiveTransition(latestTouchPoint.y, targetOffset: targetOffsetToReachBottom, escapeVelocity: finalVerticalVelocity) {
                    
                    presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
                }
            }
            
        default:
            break
        }
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
    
    func closeAnimation(duration: NSTimeInterval, completion: ((Bool) -> Void)?) {
        
        guard (self.isAnimating == false) else { return }
        isAnimating = true
        closeButtonActionInitiationBlock?()
        imageViewModel.displacedView.hidden = true
        
//        UIView.animateWithDuration(hideCloseButtonDuration, animations: { self.closeButton.alpha = 0.0 })
//        
        UIView.animateWithDuration(duration, animations: {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            self.blackOverlayView.alpha = 0.0
//            self.closeButton.alpha = 0.0
            self.view.transform = CGAffineTransformIdentity
            self.view.bounds = (self.applicationWindow?.bounds)!
            self.imageView.frame = CGRectIntegral(self.applicationWindow!.convertRect(self.imageViewModel.displacedView.bounds, fromView: self.imageViewModel.displacedView))
            
            }) { (finished) -> Void in
                completion?(finished)
                if finished {
                    NSNotificationCenter.defaultCenter().removeObserver(self)
                    self.applicationWindow!.windowLevel = UIWindowLevelNormal
                    
                    self.imageViewModel.displacedView.hidden = false
                    self.isAnimating = false
                    
                    self.closeButtonActionCompletionBlock?()
                    self.dismissCompletionBlock?()
                }
        }
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if  gestureRecognizer == panGestureRecognizer {
            
            let velocity = panGestureRecognizer.velocityInView(panGestureRecognizer.view)
            return fabs(velocity.y) > fabs(velocity.x)
        }
        
        return false
    }
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    func rotationAdjustedBounds() -> CGRect {
        guard let window = applicationWindow else { return CGRectZero }
        guard isPortraitOnly else {
            return window.bounds
        }
        
        return (UIDevice.currentDevice().orientation.isLandscape) ? CGRect(origin: CGPointZero, size: window.bounds.size.inverted()): window.bounds
    }
    
    // MARK: - KVO
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if (dynamicTransparencyActive == true && keyPath == "contentOffset") {
            
//            let transparencyMultiplier: CGFloat = 10
//            let velocityMultiplier: CGFloat = 300
            
            let distanceToEdge = (scrollView.bounds.height / 2) + (imageView.bounds.height / 2)
            
            self.blackOverlayView.alpha = 1 - fabs(scrollView.contentOffset.y / distanceToEdge)
//            closeButton.alpha = 1 - fabs(scrollView.contentOffset.y / distanceToEdge) * transparencyMultiplier
            
//            let newY = CGFloat(closeButtonPadding) - abs(scrollView.contentOffset.y / distanceToEdge) * velocityMultiplier
//            closeButton.frame = CGRect(origin: CGPoint(x: closeButton.frame.origin.x, y: newY), size: closeButton.frame.size)
        }
    }
}
