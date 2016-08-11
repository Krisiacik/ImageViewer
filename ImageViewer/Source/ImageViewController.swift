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

final class ImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    
    /// UI
    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    let blackOverlayView = UIView()
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
    var applicationWindow: UIWindow? {
        return UIApplication.sharedApplication().delegate?.window?.flatMap { $0 }
    }
    
    /// DELEGATE
    weak var delegate: ImageViewControllerDelegate?
    
    /// MODEL & STATE
    private let imageProvider: ImageProvider
    private let displacedView: UIView   
    private let imageCount: Int
    private let startIndex: Int
    
    weak private var fadeInHandler: ImageFadeInHandler?
    let index: Int
    private let showDisplacedImage: Bool
    private var swipingToDismiss: SwipeToDismiss?
    private var isAnimating = false
    private var dynamicTransparencyActive = false
    private var pagingMode: GalleryPagingMode = .Standard
    private var backgroundColor: UIColor = .blackColor()

    /// LOCAL CONFIG
    private let thresholdVelocity: CGFloat = 500 // The speed of swipe needs to be at least this amount of pixels per second for the swipe to finish dismissal.
    private let rotationAnimationDuration = 0.2
    private let hideCloseButtonDuration    = 0.05
    private let zoomDuration = 0.2
    private let itemContentSize = CGSize(width: 100, height: 100)

    /// INTERACTIONS
    private let singleTapRecognizer = UITapGestureRecognizer()
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let panGestureRecognizer = UIPanGestureRecognizer()
    
    // TRANSITIONS
    private var swipeToDismissTransition: GallerySwipeToDismissTransition?
    
    init(imageProvider: ImageProvider, configuration: GalleryConfiguration, imageCount: Int, displacedView: UIView, startIndex: Int,  imageIndex: Int, showDisplacedImage: Bool, fadeInHandler: ImageFadeInHandler?, delegate: ImageViewControllerDelegate?) {

        self.imageProvider = imageProvider
        self.imageCount = imageCount
        self.displacedView = displacedView
        self.startIndex = startIndex
        self.index = imageIndex
        self.showDisplacedImage = showDisplacedImage
        self.fadeInHandler = fadeInHandler
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        
        configuration.forEach { configurationItem in
            
            switch configurationItem {

            case .SpinnerColor(let color):     activityIndicatorView.color = color
            case .SpinnerStyle(let style):     activityIndicatorView.activityIndicatorViewStyle = style
            case .PagingMode(let mode):        pagingMode = mode
            case .BackgroundColor(let color):  backgroundColor = color
            default: break
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ImageViewController.adjustImageViewForRotation), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        self.view.backgroundColor = UIColor.clearColor()
        blackOverlayView.backgroundColor = backgroundColor
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
            updateImageAndContentSize(screenshotFromView(displacedView))
        }
        
        self.fetchImage(self.index)  { [weak self] image in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let fullSizedImage = image {
                    self?.updateImageAndContentSize(fullSizedImage)
                }
            }
        }
    }
    
    func fetchImage(atIndex: Int, completion: UIImage? -> Void) {
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        
        dispatch_async(backgroundQueue) {
            
            self.imageProvider.provideImage(atIndex: atIndex, completion: completion)
        }
    }
    
    func configureScrollView() {
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = itemContentSize
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    func configureGestureRecognizers() {
        
        singleTapRecognizer.addTarget(self, action: #selector(ImageViewController.scrollViewDidSingleTap(_:)))
        singleTapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTapRecognizer)
        
        doubleTapRecognizer.addTarget(self, action: #selector(ImageViewController.scrollViewDidDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        
        panGestureRecognizer.addTarget(self, action: #selector(ImageViewController.scrollViewDidSwipeToDismiss(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func createViewHierarchy() {
        
        scrollView.addSubview(imageView)
        self.view.addSubview(scrollView)
    }
    
    func updateImageAndContentSize(image: UIImage) {

        activityIndicatorView.stopAnimating()

        let boundingSize = rotationAdjustedBounds().size
        let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: image.size)
        let isHorizontalFit = abs(boundingSize.width - aspectFitSize.width) < 1

        scrollView.contentSize = aspectFitSize
        scrollView.zoomScale = scrollView.minimumZoomScale
        scrollView.maximumZoomScale = isHorizontalFit ? boundingSize.height / aspectFitSize.height : boundingSize.width / aspectFitSize.width

        imageView.frame.size = aspectFitSize
        imageView.center = scrollView.boundsCenter

        if self.needToAnimateImage() {
            UIView.transitionWithView(self.scrollView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.imageView.image = image
                }, completion: { finished in
                    self.fadeInHandler?.addPresentedImageIndex(self.index)
            })
        } else {
            self.imageView.image = image
            self.fadeInHandler?.addPresentedImageIndex(self.index)
        }
    }

    private func needToAnimateImage() -> Bool {
        guard let fadeInHandler = fadeInHandler else { return false }

        return !fadeInHandler.wasPresented(self.index) && self.index != self.startIndex
    }

    func adjustImageViewForRotation() {
        
        guard self.imageView.bounds != CGRect.zero else { return }
        
        let imageViewBounds = self.imageView.bounds
        
        guard UIDevice.currentDevice().orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        UIView.animateWithDuration(rotationAnimationDuration, animations: { [weak self] () -> Void in
            
            self?.imageView.bounds.size = aspectFitContentSize(forBoundingSize: rotationAdjustedBounds().size, contentSize: imageViewBounds.size)
            self?.scrollView.zoomScale = self?.scrollView.minimumZoomScale ?? 1.0
            }) { [weak self] finished in
                
                self?.isAnimating = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = backgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.delegate?.imageViewControllerDidAppear(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
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
                scrollView.zoomScale = scrollView.minimumZoomScale
            }
            }, completion: nil)
    }
    
    func scrollViewDidSingleTap(recognizer: UITapGestureRecognizer) {
        
        self.delegate?.imageViewControllerDidSingleTap(self)
    }
    
    func scrollViewDidDoubleTap(recognizer: UITapGestureRecognizer) {
        
        let touchPoint = recognizer.locationOfTouch(0, inView: imageView)
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: imageView.bounds.size)

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
        
        guard imageView.image != nil else {  return } // a swipe gesture with empty scrollview doesn't make sense
        guard scrollView.zoomScale == scrollView.minimumZoomScale else {  return } // UX decision
        
        let currentVelocity = recognizer.velocityInView(self.view)
        let currentTouchPoint = recognizer.translationInView(view)
        
        if swipingToDismiss == nil { swipingToDismiss = (fabs(currentVelocity.x) > fabs(currentVelocity.y)) ? .Horizontal : .Vertical }
        guard let swipingToDismissInProgress = swipingToDismiss else { return }
        
        displacedView.hidden = false
        dynamicTransparencyActive = true
        
        
        switch recognizer.state {
            
        case .Began:
            swipeToDismissTransition = GallerySwipeToDismissTransition(presentingViewController: self.presentingViewController, scrollView: self.scrollView)
            
        case .Changed:
            self.handleSwipeToDismissInProgress(swipingToDismissInProgress, forTouchPoint: currentTouchPoint)
            
        case .Ended:
            self.handleSwipeToDismissEnded(swipingToDismissInProgress, finalVelocity: currentVelocity, finalTouchPoint: currentTouchPoint)
            
        default:
            break
        }
    }
    
    func handleSwipeToDismissInProgress(swipeOrientation: SwipeToDismiss, forTouchPoint touchPoint: CGPoint) {
        
        switch (swipeOrientation, index) {
            
        case (.Horizontal, 0) where self.imageCount != 1:
            
            /// edge case horizontal first index - limits the swipe to dismiss to HORIZONTAL RIGHT direction.
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: min(0, -touchPoint.x))
            
        case (.Horizontal, self.imageCount - 1) where self.imageCount != 1:
            
            /// edge case horizontal last index - limits the swipe to dismiss to HORIZONTAL LEFT direction.
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: max(0, -touchPoint.x))
            
        case (.Horizontal, _):
            
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: -touchPoint.x) // all the rest
            
        case (.Vertical, _):
            
            swipeToDismissTransition?.updateInteractiveTransition(verticalOffset: -touchPoint.y) // all the rest
        }
    }
    
    func handleSwipeToDismissEnded(swipeOrientation: SwipeToDismiss, finalVelocity velocity: CGPoint, finalTouchPoint touchPoint: CGPoint) {
        
        let presentingViewController = self.presentingViewController
        let parentViewController = self.parentViewController as? GalleryViewController
        
        let maxIndex = self.imageCount - 1
        
        switch (swipeOrientation, index) {
            
        case (.Vertical, _) where velocity.y < -thresholdVelocity: /// All images VERTICAL UP direction
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation, touchPoint: touchPoint.y, targetOffset: (view.bounds.height / 2) + (imageView.bounds.height / 2), escapeVelocity: velocity.y) {  [weak self] in
                self?.swipingToDismiss = nil
                self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                parentViewController?.swipedToDismissCompletion?()
                presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
            }
            
        case (.Vertical, _) where thresholdVelocity < velocity.y: /// All images VERTICAL DOWN direction
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation, touchPoint: touchPoint.y, targetOffset: -(view.bounds.height / 2) - (imageView.bounds.height / 2), escapeVelocity: velocity.y) {  [weak self] in
                self?.swipingToDismiss = nil
                self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                parentViewController?.swipedToDismissCompletion?()
                presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
            }
            
        case (.Horizontal, 0) where thresholdVelocity < velocity.x: /// First image HORIZONTAL RIGHT direction
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation, touchPoint: touchPoint.x, targetOffset: -(view.bounds.width / 2) - (imageView.bounds.width / 2), escapeVelocity: velocity.x) {  [weak self] in
                self?.swipingToDismiss = nil
                self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                parentViewController?.swipedToDismissCompletion?()
                presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
            }
            
        case (.Horizontal, maxIndex) where velocity.x < -thresholdVelocity: /// Last image HORIZONTAL LEFT direction
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation, touchPoint: touchPoint.x, targetOffset: (view.bounds.width / 2) + (imageView.bounds.width / 2), escapeVelocity: velocity.x) {  [weak self] in
                self?.swipingToDismiss = nil
                self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                parentViewController?.swipedToDismissCompletion?()
                presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
            }
            
        default:
            
            swipeToDismissTransition?.cancelTransition() { [weak self] in
                self?.swipingToDismiss = nil
            }
        }
    }
    
    func closeAnimation(duration: NSTimeInterval, completion: ((Bool) -> Void)?) {
        
        guard (self.isAnimating == false) else { return }
        isAnimating = true
        
        displacedView.hidden = true
        
        UIView.animateWithDuration(duration, animations: {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            self.blackOverlayView.alpha = 0.0
            
            if isPortraitOnly() {
                self.imageView.transform = CGAffineTransformInvert(rotationTransform())
            }
            
            /// Get position of displaced view in window
            let displacedViewInWindowPosition = self.applicationWindow!.convertRect(self.displacedView.bounds, fromView: self.displacedView)
            /// Translate that to gallery view
            let displacedViewInOurCoordinateSystem = self.view.convertRect(displacedViewInWindowPosition, fromView: self.applicationWindow!)
            
            self.imageView.frame = displacedViewInOurCoordinateSystem
            
            }) { [weak self] finished in
                
                completion?(finished)
                
                if finished {
                    
                    self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                    
                    self?.displacedView.hidden = false
                    self?.isAnimating = false
                }
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        /// We only care about the pan gesture recognizer
        guard gestureRecognizer == panGestureRecognizer else { return false }
        
        let velocity = panGestureRecognizer.velocityInView(panGestureRecognizer.view)

        /// If the vertical velocity (in both up and bottom direction) is faster then horizontal velocity..it is clearly a vertical swipe to dismiss so we allow it.
        guard fabs(velocity.y) < fabs(velocity.x) else { return true }

        /// A special case for horizontal "swipe to dismiss" is when the gallery has carousel mode OFF, then it is possible to reach the beginning or the end of image set while paging. PAging will stop at index = 0 or at index.max. In this case we allow to jump out from the gallery also via horizontal swipe to dismiss.
        if (self.index == 0 && velocity.x > 0) || (self.index == self.imageCount - 1 && velocity.x < 0) {
            
            return (pagingMode == .Standard)
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