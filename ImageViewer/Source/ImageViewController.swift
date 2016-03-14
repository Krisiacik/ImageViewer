//
//  ImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit


enum SwipeToDismiss {
    
    case Horizontal
    case Vertical
}

class ImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    
    //UI
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    let blackOverlayView = UIView()
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
    var applicationWindow: UIWindow? {
        return UIApplication.sharedApplication().delegate?.window?.flatMap { $0 }
    }
    
    //DELEGATE
    weak var delegate: ImageViewControllerDelegate?
    
    //MODEL & STATE
    let imageViewModel: GalleryViewModel
    weak private var fadeInHandler: ImageFadeInHandler?
    let index: Int
    let showDisplacedImage: Bool
    private var legacyIsSwiping = false
    private var swipingToDismiss: SwipeToDismiss?
    private var isAnimating = false
    private var dynamicTransparencyActive = false
    
    //LOCAL CONFIG
    private let thresholdVelocity: CGFloat = 1000 // It works as a threshold.
    private let rotationAnimationDuration = 0.2
    private let hideCloseButtonDuration    = 0.05
    private let zoomDuration = 0.2
    
    //INTERACTIONS
    private let singleTapRecognizer = UITapGestureRecognizer()
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    //TRANSITIONS
    private var swipeTodismissTransition: GallerySwipeToDismissTransition?
    
    //LIFE CYCLE BLOCKS
    var showInitiationBlock: (Void -> Void)? //executed right before the image animation into its final position starts.
    var showCompletionBlock: (Void -> Void)? //executed as the last step after all the show animations.
    var closeButtonActionInitiationBlock: (Void -> Void)? //executed as the first step before the button's close action starts.
    var closeButtonActionCompletionBlock: (Void -> Void)? //executed as the last step for close button's close action.
    var swipeToDismissInitiationBlock: (Void -> Void)? //executed as the first step for swipe to dismiss action.
    var swipeToDismissCompletionBlock: (Void -> Void)? //executed as the last step for swipe to dismiss action.
    var dismissCompletionBlock: (Void -> Void)? //executed as the last step when the ImageViewer is dismissed (either via the close button, or swipe)
    
    init(imageViewModel: GalleryViewModel, configuration: GalleryConfiguration, imageIndex: Int, showDisplacedImage: Bool, fadeInHandler: ImageFadeInHandler?, delegate: ImageViewControllerDelegate?) {
        
        self.imageViewModel = imageViewModel
        self.index = imageIndex
        self.showDisplacedImage = showDisplacedImage
        self.fadeInHandler = fadeInHandler
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        
        configuration.forEach { configurationItem in
            
            switch configurationItem {
                
            case .SpinnerColor(let color):  activityIndicatorView.color = color
            case .SpinnerStyle(let style):  activityIndicatorView.activityIndicatorViewStyle = style
            default: break
                
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "adjustImageViewForRotation", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        self.view.backgroundColor = UIColor.clearColor()
        blackOverlayView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(blackOverlayView)
        self.modalPresentationStyle = .Custom
        
        activityIndicatorView.startAnimating()
        self.view.addSubview(activityIndicatorView)
        
        configureImageView()
        configureScrollView()
        configureGestureRecognizers()
        createViewHierarchy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
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
        
        singleTapRecognizer.addTarget(self, action: "scrollViewDidSingleTap:")
        singleTapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTapRecognizer)
        
        doubleTapRecognizer.addTarget(self, action: "scrollViewDidDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        
        panGestureRecognizer.addTarget(self, action: "scrollViewDidSwipeToDismiss:")
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func createViewHierarchy() {
        
        scrollView.addSubview(imageView)
        self.view.addSubview(scrollView)
    }
    
    func updateImageAndContentSize(image: UIImage) {
        
        activityIndicatorView.stopAnimating()
        
        if imageView.image == nil {
            
            scrollView.zoomScale = 1
            let aspectFitSize = aspectFitContentSize(forBoundingSize: rotationAdjustedBounds().size, contentSize: image.size)
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
    
    func adjustImageViewForRotation() {
        
        guard UIDevice.currentDevice().orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        UIView.animateWithDuration(rotationAnimationDuration, animations: { () -> Void in
            
            self.imageView.bounds.size = aspectFitContentSize(forBoundingSize: rotationAdjustedBounds().size, contentSize: self.imageView.bounds.size)
            self.scrollView.zoomScale = 1.0
            }) { [weak self] finished in
                
                self?.isAnimating = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.scrollView.zoomScale = 1.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = self.view.bounds
        blackOverlayView.frame = self.view.bounds
        imageView.center = scrollView.boundsCenter
        activityIndicatorView.center = self.view.boundsCenter
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        rotate(toBoundingSize: size, transitionCoordinator: coordinator)
    }
    
    func rotate(toBoundingSize boundingSize: CGSize, transitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ [weak self] transitionContext in
            
            if let imageView = self?.imageView, _ = imageView.image, scrollView = self?.scrollView {
                
                imageView.bounds.size = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: imageView.bounds.size)
                scrollView.zoomScale = 1
            }
            }, completion: nil)
    }
    
    func scrollViewDidSingleTap(recognizer: UITapGestureRecognizer) {
        
        self.delegate?.imageViewControllerDidSingleTap(self)
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
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }
    
    func scrollViewDidSwipeToDismiss(recognizer: UIPanGestureRecognizer) {
 
        guard self.imageView.image != nil else {  return } //a swipe gesture with empty scrollview doesn't make sense
        guard scrollView.zoomScale == scrollView.minimumZoomScale else {  return } //UX decision
        
        let velocity = recognizer.velocityInView(self.view)
 
        if swipingToDismiss == nil {
            
            if fabs(velocity.x) > fabs(velocity.y) {
                
                swipingToDismiss = .Horizontal
                print("HORIZONTAL")
            }
            else {
                swipingToDismiss = .Vertical
                print("VERTICAL")
            }
        }
        
        guard let swipingToDismissInProgress = swipingToDismiss else { return }

        
        swipeToDismissInitiationBlock?()
        imageViewModel.displacedView.hidden = false
        dynamicTransparencyActive = true
        
        let latestTouchPoint = recognizer.translationInView(view)
        
        switch recognizer.state {
            
        case .Began:
            
            swipeTodismissTransition = GallerySwipeToDismissTransition(presentingViewController: self.presentingViewController, scrollView: self.scrollView)
            applicationWindow!.windowLevel = UIWindowLevelNormal
            
        case .Changed:

            switch swipingToDismissInProgress {
                
            case .Horizontal:
                
                swipeTodismissTransition?.updateInteractiveTransition(horizontalOffset: -latestTouchPoint.x)
                
            case .Vertical:
                
                swipeTodismissTransition?.updateInteractiveTransition(verticalOffset: -latestTouchPoint.y)
            }
            
        case .Ended:
            
            let presentingViewController = self.presentingViewController
            
            //in points per second
            var finalVelocity: CGFloat
            var latestTouchPointDirectionalComponent: CGFloat
            var targetOffset: CGFloat
            
            switch swipingToDismissInProgress {
                
            case .Horizontal:
                
                finalVelocity = recognizer.velocityInView(view).x
                latestTouchPointDirectionalComponent = latestTouchPoint.x
                targetOffset = (view.bounds.width / 2) + (imageView.bounds.width / 2)
                
            case .Vertical:
                
                finalVelocity = recognizer.velocityInView(view).y
                latestTouchPointDirectionalComponent = latestTouchPoint.y
                targetOffset = (view.bounds.height / 2) + (imageView.bounds.height / 2)
            }
            
            if finalVelocity < -thresholdVelocity {
                
                swipeTodismissTransition?.finishInteractiveTransition(latestTouchPointDirectionalComponent, targetOffset: targetOffset, escapeVelocity: finalVelocity) {  [weak self] in
                    
                    self?.legacyIsSwiping = false
                    self?.swipingToDismiss = nil
                    presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
                }
            }
            else if finalVelocity >= -thresholdVelocity && finalVelocity <= thresholdVelocity {
                
                swipeTodismissTransition?.cancelTransition() { [weak self] in
                    self?.legacyIsSwiping = false
                    self?.swipingToDismiss = nil
                    
                }
            }
            else {
                swipeTodismissTransition?.finishInteractiveTransition(latestTouchPointDirectionalComponent, targetOffset: -targetOffset, escapeVelocity: finalVelocity) { [weak self] in
                    
                    self?.legacyIsSwiping = false
                    self?.swipingToDismiss = nil
                    presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
                }
            }
            
        default:
            break
        }
    }
    
    func closeAnimation(duration: NSTimeInterval, completion: ((Bool) -> Void)?) {
        
        guard (self.isAnimating == false) else { return }
        isAnimating = true
        closeButtonActionInitiationBlock?()
        
        imageViewModel.displacedView.hidden = true
        
        UIView.animateWithDuration(duration, animations: {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            self.blackOverlayView.alpha = 0.0
            
            if isPortraitOnly() {
                self.imageView.transform = CGAffineTransformInvert(rotationTransform())
            }
            
            //get position of displaced view in window
            let displacedViewInWindowPosition = self.applicationWindow!.convertRect(self.imageViewModel.displacedView.bounds, fromView: self.imageViewModel.displacedView)
            //translate that to gallery view
            let displacedViewInOurCoordinateSystem = self.view.convertRect(displacedViewInWindowPosition, fromView: self.applicationWindow!)
            
            self.imageView.frame = displacedViewInOurCoordinateSystem
            
            }) { (finished) -> Void in
                completion?(finished)
                if finished {
                    
                    self.applicationWindow!.windowLevel = UIWindowLevelNormal
                    
                    self.imageViewModel.displacedView.hidden = false
                    self.isAnimating = false
                    
                    self.closeButtonActionCompletionBlock?()
                    self.dismissCompletionBlock?()
                }
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //we only care about the pan gesture recognizer & if it has a valid case for "swipe to dismiss" gesture...
        guard gestureRecognizer == panGestureRecognizer else { return false }
        
        let velocity = panGestureRecognizer.velocityInView(panGestureRecognizer.view)
        
        //if the vertical velocity (in both up and bottom direction) is faster then horizontal velocity..it is clearly a vertical swipe to dismiss so we allow it.
        guard fabs(velocity.y) < fabs(velocity.x) else { return true }
        
        
        //a special case for horizontal "swipe to dismiss" is when the gallery has carousel mode OFF, then it is possible to reach the beginning or the end of image set while paging. PAging will stop at index = 0 or at index.max. In this case we allow to jump out from the gallery also via horizontal swipe to dismiss.
        if (self.index == 0 && velocity.x > 0) || (self.index == self.imageViewModel.imageCount - 1 && velocity.x < 0) {
            
            return true
        }
        
        return false
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let swipingToDissmissInProgress = swipingToDismiss else { return }
        guard keyPath == "contentOffset" else { return }
        
        let distanceToEdge: CGFloat
        let percentDistance: CGFloat
        
        switch swipingToDissmissInProgress {
            
        case .Horizontal:
            
            distanceToEdge = (scrollView.bounds.width / 2) + (imageView.bounds.width / 2)
            percentDistance = fabs(scrollView.contentOffset.x / distanceToEdge)
            
        case .Vertical:
            
            distanceToEdge = (scrollView.bounds.height / 2) + (imageView.bounds.height / 2)
            percentDistance = fabs(scrollView.contentOffset.y / distanceToEdge)
        }
        
        
        if dynamicTransparencyActive == true {
            self.blackOverlayView.alpha = 1 - percentDistance
        }
        
        if let delegate = self.delegate {
            delegate.imageViewController(self, didSwipeToDismissWithDistanceToEdge: percentDistance)
        }
    }
}
