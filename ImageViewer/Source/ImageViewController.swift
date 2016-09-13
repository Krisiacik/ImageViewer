//
//  ImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

enum SwipeToDismiss {
    
    case horizontal
    case vertical
}

final class ImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    
    /// UI
    fileprivate let scrollView = UIScrollView()
    fileprivate let imageView = UIImageView()
    let blackOverlayView = UIView()
    fileprivate let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    var applicationWindow: UIWindow? {
        return UIApplication.shared.delegate?.window?.flatMap { $0 }
    }
    
    /// DELEGATE
    weak var delegate: ImageViewControllerDelegate?
    
    /// MODEL & STATE
    fileprivate let imageProvider: ImageProvider
    fileprivate let displacedView: UIView   
    fileprivate let imageCount: Int
    fileprivate let startIndex: Int
    
    weak fileprivate var fadeInHandler: ImageFadeInHandler?
    let index: Int
    fileprivate let showDisplacedImage: Bool
    fileprivate var swipingToDismiss: SwipeToDismiss?
    fileprivate var isAnimating = false
    fileprivate var dynamicTransparencyActive = false
    fileprivate var pagingMode: GalleryPagingMode = .standard
    fileprivate var backgroundColor: UIColor = .black

    /// LOCAL CONFIG
    fileprivate let thresholdVelocity: CGFloat = 500 // The speed of swipe needs to be at least this amount of pixels per second for the swipe to finish dismissal.
    fileprivate let rotationAnimationDuration = 0.2
    fileprivate let hideCloseButtonDuration    = 0.05
    fileprivate let zoomDuration = 0.2
    fileprivate let itemContentSize = CGSize(width: 100, height: 100)

    /// INTERACTIONS
    fileprivate let singleTapRecognizer = UITapGestureRecognizer()
    fileprivate let doubleTapRecognizer = UITapGestureRecognizer()
    fileprivate let panGestureRecognizer = UIPanGestureRecognizer()
    
    // TRANSITIONS
    fileprivate var swipeToDismissTransition: GallerySwipeToDismissTransition?
    
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

            case .spinnerColor(let color):     activityIndicatorView.color = color
            case .spinnerStyle(let style):     activityIndicatorView.activityIndicatorViewStyle = style
            case .pagingMode(let mode):        pagingMode = mode
            case .backgroundColor(let color):  backgroundColor = color
            default: break
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewController.adjustImageViewForRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.view.backgroundColor = UIColor.clear
        blackOverlayView.backgroundColor = backgroundColor
        self.view.addSubview(blackOverlayView)
        self.modalPresentationStyle = .custom
        
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
        
        NotificationCenter.default.removeObserver(self)
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    func configureImageView() {
        
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        if showDisplacedImage {
            updateImageAndContentSize(screenshotFromView(displacedView))
        }
        
        self.fetchImage(self.index)  { [weak self] image in
            
            DispatchQueue.main.async {
                
                if let fullSizedImage = image {
                    self?.updateImageAndContentSize(fullSizedImage)
                }
            }
        }
    }
    
    func fetchImage(_ atIndex: Int, completion: @escaping (UIImage?) -> Void) {
        
        DispatchQueue.global(qos: .background).async {
            
            self.imageProvider.provideImage(atIndex: atIndex, completion: completion)
        }
    }
    
    func configureScrollView() {
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.contentOffset = CGPoint.zero
        scrollView.contentSize = itemContentSize
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    func configureGestureRecognizers() {
        
        singleTapRecognizer.addTarget(self, action: #selector(ImageViewController.scrollViewDidSingleTap(_:)))
        singleTapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTapRecognizer)
        
        doubleTapRecognizer.addTarget(self, action: #selector(ImageViewController.scrollViewDidDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
        
        panGestureRecognizer.addTarget(self, action: #selector(ImageViewController.scrollViewDidSwipeToDismiss(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func createViewHierarchy() {
        
        scrollView.addSubview(imageView)
        self.view.addSubview(scrollView)
    }
    
    func updateImageAndContentSize(_ image: UIImage) {

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
            UIView.transition(with: self.scrollView, duration: 0.5, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
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
        
        guard UIDevice.current.orientation.isFlat == false &&
            isAnimating == false else { return }
        
        isAnimating = true
        
        UIView.animate(withDuration: rotationAnimationDuration, animations: { [weak self] () -> Void in
            
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.delegate?.imageViewControllerDidAppear(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        rotate(toBoundingSize: size, transitionCoordinator: coordinator)
    }
    
    func rotate(toBoundingSize boundingSize: CGSize, transitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { [weak self] transitionContext in
            
            if let imageView = self?.imageView, let _ = imageView.image, let scrollView = self?.scrollView {
                
                imageView.bounds.size = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: imageView.bounds.size)
                scrollView.zoomScale = scrollView.minimumZoomScale
            }
            }, completion: nil)
    }
    
    @objc fileprivate func scrollViewDidSingleTap(_ recognizer: UITapGestureRecognizer) {
        
        self.delegate?.imageViewControllerDidSingleTap(self)
    }
    
    func scrollViewDidDoubleTap(_ recognizer: UITapGestureRecognizer) {
        
        let touchPoint = recognizer.location(ofTouch: 0, in: imageView)
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: imageView.bounds.size)

        if (scrollView.zoomScale == 1.0 || scrollView.zoomScale > aspectFillScale) {
            
            let zoomRectangle = zoomRect(ForScrollView: scrollView, scale: aspectFillScale, center: touchPoint)
            
            UIView.animate(withDuration: zoomDuration, animations: {
                self.scrollView.zoom(to: zoomRectangle, animated: false)
            })
        }
        else  {
            UIView.animate(withDuration: zoomDuration, animations: {
                self.scrollView.setZoomScale(1.0, animated: false)
            })
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }
    
    func scrollViewDidSwipeToDismiss(_ recognizer: UIPanGestureRecognizer) {
        
        guard imageView.image != nil else {  return } // a swipe gesture with empty scrollview doesn't make sense
        guard scrollView.zoomScale == scrollView.minimumZoomScale else {  return } // UX decision
        
        let currentVelocity = recognizer.velocity(in: self.view)
        let currentTouchPoint = recognizer.translation(in: view)
        
        if swipingToDismiss == nil { swipingToDismiss = (fabs(currentVelocity.x) > fabs(currentVelocity.y)) ? .horizontal : .vertical }
        guard let swipingToDismissInProgress = swipingToDismiss else { return }
        
        displacedView.isHidden = false
        dynamicTransparencyActive = true
        
        
        switch recognizer.state {
            
        case .began:
            swipeToDismissTransition = GallerySwipeToDismissTransition(presentingViewController: self.presentingViewController, scrollView: self.scrollView)
            
        case .changed:
            self.handleSwipeToDismissInProgress(swipingToDismissInProgress, forTouchPoint: currentTouchPoint)
            
        case .ended:
            self.handleSwipeToDismissEnded(swipingToDismissInProgress, finalVelocity: currentVelocity, finalTouchPoint: currentTouchPoint)
            
        default:
            break
        }
    }
    
    func handleSwipeToDismissInProgress(_ swipeOrientation: SwipeToDismiss, forTouchPoint touchPoint: CGPoint) {
        
        switch (swipeOrientation, index) {
            
        case (.horizontal, 0) where self.imageCount != 1:
            
            /// edge case horizontal first index - limits the swipe to dismiss to HORIZONTAL RIGHT direction.
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: min(0, -touchPoint.x))
            
        case (.horizontal, self.imageCount - 1) where self.imageCount != 1:
            
            /// edge case horizontal last index - limits the swipe to dismiss to HORIZONTAL LEFT direction.
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: max(0, -touchPoint.x))
            
        case (.horizontal, _):
            
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: -touchPoint.x) // all the rest
            
        case (.vertical, _):
            
            swipeToDismissTransition?.updateInteractiveTransition(verticalOffset: -touchPoint.y) // all the rest
        }
    }
    
    func handleSwipeToDismissEnded(_ swipeOrientation: SwipeToDismiss, finalVelocity velocity: CGPoint, finalTouchPoint touchPoint: CGPoint) {
        
        let presentingViewController = self.presentingViewController
        let parentViewController = self.parent as? GalleryViewController
        
        let maxIndex = self.imageCount - 1
        
        switch (swipeOrientation, index) {
            
        case (.vertical, _) where velocity.y < -thresholdVelocity: /// All images VERTICAL UP direction
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation, touchPoint: touchPoint.y, targetOffset: (view.bounds.height / 2) + (imageView.bounds.height / 2), escapeVelocity: velocity.y) {  [weak self] in
                self?.swipingToDismiss = nil
                self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                parentViewController?.swipedToDismissCompletion?()
                presentingViewController?.dismiss(animated: false, completion: nil)
            }
            
        case (.vertical, _) where thresholdVelocity < velocity.y: /// All images VERTICAL DOWN direction
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation, touchPoint: touchPoint.y, targetOffset: -(view.bounds.height / 2) - (imageView.bounds.height / 2), escapeVelocity: velocity.y) {  [weak self] in
                self?.swipingToDismiss = nil
                self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                parentViewController?.swipedToDismissCompletion?()
                presentingViewController?.dismiss(animated: false, completion: nil)
            }
            
        case (.horizontal, 0) where thresholdVelocity < velocity.x: /// First image HORIZONTAL RIGHT direction
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation, touchPoint: touchPoint.x, targetOffset: -(view.bounds.width / 2) - (imageView.bounds.width / 2), escapeVelocity: velocity.x) {  [weak self] in
                self?.swipingToDismiss = nil
                self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                parentViewController?.swipedToDismissCompletion?()
                presentingViewController?.dismiss(animated: false, completion: nil)
            }
            
        case (.horizontal, maxIndex) where velocity.x < -thresholdVelocity: /// Last image HORIZONTAL LEFT direction
            
            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation, touchPoint: touchPoint.x, targetOffset: (view.bounds.width / 2) + (imageView.bounds.width / 2), escapeVelocity: velocity.x) {  [weak self] in
                self?.swipingToDismiss = nil
                self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                parentViewController?.swipedToDismissCompletion?()
                presentingViewController?.dismiss(animated: false, completion: nil)
            }
            
        default:
            
            swipeToDismissTransition?.cancelTransition() { [weak self] in
                self?.swipingToDismiss = nil
            }
        }
    }
    
    func closeAnimation(_ duration: TimeInterval, completion: ((Bool) -> Void)?) {
        
        guard (self.isAnimating == false) else { return }
        isAnimating = true
        
        displacedView.isHidden = true
        
        UIView.animate(withDuration: duration, animations: {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            self.blackOverlayView.alpha = 0.0
            
            if isPortraitOnly() {
                self.imageView.transform = rotationTransform().inverted()
            }
            
            /// Get position of displaced view in window
            let displacedViewInWindowPosition = self.applicationWindow!.convert(self.displacedView.bounds, from: self.displacedView)
            /// Translate that to gallery view
            let displacedViewInOurCoordinateSystem = self.view.convert(displacedViewInWindowPosition, from: self.applicationWindow!)
            
            self.imageView.frame = displacedViewInOurCoordinateSystem
            
            }) { [weak self] finished in
                
                completion?(finished)
                
                if finished {
                    
                    self?.applicationWindow?.windowLevel = UIWindowLevelNormal
                    
                    self?.displacedView.isHidden = false
                    self?.isAnimating = false
                }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        /// We only care about the pan gesture recognizer
        guard gestureRecognizer == panGestureRecognizer else { return false }
        
        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view)

        /// If the vertical velocity (in both up and bottom direction) is faster then horizontal velocity..it is clearly a vertical swipe to dismiss so we allow it.
        guard fabs(velocity.y) < fabs(velocity.x) else { return true }

        /// A special case for horizontal "swipe to dismiss" is when the gallery has carousel mode OFF, then it is possible to reach the beginning or the end of image set while paging. PAging will stop at index = 0 or at index.max. In this case we allow to jump out from the gallery also via horizontal swipe to dismiss.
        if (self.index == 0 && velocity.x > 0) || (self.index == self.imageCount - 1 && velocity.x < 0) {
            
            return (pagingMode == .standard)
        }
        
        return false
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    // MARK: - KVO

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let swipingToDissmissInProgress = swipingToDismiss else { return }
        guard keyPath == "contentOffset" else { return }
        
        let distanceToEdge: CGFloat
        let percentDistance: CGFloat
        
        switch swipingToDissmissInProgress {
            
        case .horizontal:
            
            distanceToEdge = (scrollView.bounds.width / 2) + (imageView.bounds.width / 2)
            percentDistance = fabs(scrollView.contentOffset.x / distanceToEdge)
            
        case .vertical:
            
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
