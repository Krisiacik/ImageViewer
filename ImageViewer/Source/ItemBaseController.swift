//
//  ItemBaseController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/08/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit


protocol ItemView {

    var image: UIImage? { get set }
}

class ItemBaseController<T: UIView where T: ItemView>: UIViewController, ItemController, UIGestureRecognizerDelegate, UIScrollViewDelegate {

    //UI
    var itemView = T()
    let scrollView = UIScrollView()

    //DELEGATE / DATASOURCE
    var delegate: ItemControllerDelegate?
    var displacedViewsDatasource: GalleryDisplacedViewsDatasource?

    //STATE
    let index: Int
    var isInitialController = false
    let itemCount: Int
    var swipingToDismiss: SwipeToDismiss?
    private var isAnimating = false

    //CONFIGURATION
    private var presentationStyle = GalleryPresentationStyle.Displacement
    private var doubleTapToZoomDuration = 0.2
    private var displacementDuration: NSTimeInterval = 0.3
    private var reverseDisplacementDuration: NSTimeInterval = 0.2
    private var itemFadeDuration: NSTimeInterval = 0.3
    private var displacementTimingCurve: UIViewAnimationCurve = .Linear
    private var displacementSpringBounce: CGFloat = 0.7
    private let minimumZoomScale: CGFloat = 1
    private var maximumZoomScale: CGFloat = 4
    private var pagingMode: GalleryPagingMode = .Standard
    private var thresholdVelocity: CGFloat = 500 // The speed of swipe needs to be at least this amount of pixels per second for the swipe to finish dismissal.

    /// INTERACTIONS
    private let singleTapRecognizer = UITapGestureRecognizer()
    private let doubleTapRecognizer = UITapGestureRecognizer()
    private let swipeToDismissRecognizer = UIPanGestureRecognizer()

    // TRANSITIONS
    private var swipeToDismissTransition: GallerySwipeToDismissTransition?


    // MARK: - Initializers

    init(index: Int, itemCount: Int, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.index = index
        self.itemCount = itemCount
        self.isInitialController = isInitialController

        for item in configuration {

            switch item {

            case .SwipeToDismissThresholdVelocity(let velocity):    thresholdVelocity = velocity
            case .DoubleTapToZoomDuration(let duration):            doubleTapToZoomDuration = duration
            case .PresentationStyle(let style):                     presentationStyle = style
            case .PagingMode(let mode):                             pagingMode = mode
            case .DisplacementDuration(let duration):               displacementDuration = duration
            case .ReverseDisplacementDuration(let duration):        reverseDisplacementDuration = duration
            case .DisplacementTimingCurve(let curve):               displacementTimingCurve = curve
            case .MaximumZoolScale(let scale):                      maximumZoomScale = scale
            case .ItemFadeDuration(let duration):                   itemFadeDuration = duration

            case .DisplacementTransitionStyle(let style):

                switch style {

                case .SpringBounce(let bounce):                     displacementSpringBounce = bounce
                case .Normal:                                       displacementSpringBounce = 1
                }

            default: break
            }
        }

        super.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .Custom

        self.itemView.hidden = isInitialController

        configureScrollView()
        configureGestureRecognizers()
    }

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    deinit {

        self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }

    // MARK: - Configuration

    private func configureScrollView() {

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = maximumZoomScale

        scrollView.delegate = self

        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    }

    func configureGestureRecognizers() {

        singleTapRecognizer.addTarget(self, action: #selector(scrollViewDidSingleTap))
        singleTapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTapRecognizer)

        doubleTapRecognizer.addTarget(self, action: #selector(scrollViewDidDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)

        singleTapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)

        swipeToDismissRecognizer.addTarget(self, action: #selector(scrollViewDidSwipeToDismiss))
        swipeToDismissRecognizer.delegate = self
        view.addGestureRecognizer(swipeToDismissRecognizer)
    }

    private func createViewHierarchy() {

        self.view.addSubview(scrollView)
        scrollView.addSubview(itemView)
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        createViewHierarchy()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.delegate?.itemControllerWillAppear(self)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.delegate?.itemControllerDidAppear(self)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        self.delegate?.itemControllerWillDisappear(self)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let bounds = self.view.bounds
        scrollView.frame = bounds

        let aspectFitItemSize = aspectFitSize(forContentOfSize: itemView.image!.size, inBounds: self.scrollView.bounds.size)

        itemView.bounds.size = aspectFitItemSize
        scrollView.contentSize = itemView.bounds.size

        itemView.center = scrollView.boundsCenter
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {

        return itemView
    }

    // MARK: - Scroll View delegate methods

    func scrollViewDidZoom(scrollView: UIScrollView) {

        itemView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }

    func scrollViewDidSingleTap() {

        self.delegate?.itemControllerDidSingleTap(self)
    }

    func scrollViewDidDoubleTap(recognizer: UITapGestureRecognizer) {

        let touchPoint = recognizer.locationOfTouch(0, inView: itemView)
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: scrollView.bounds.size, contentSize: itemView.bounds.size)

        if (scrollView.zoomScale == 1.0 || scrollView.zoomScale > aspectFillScale) {

            let zoomRectangle = zoomRect(ForScrollView: scrollView, scale: aspectFillScale, center: touchPoint)

            UIView.animateWithDuration(doubleTapToZoomDuration, animations: { [weak self] in

                self?.scrollView.zoomToRect(zoomRectangle, animated: false)
                })
        }
        else  {
            UIView.animateWithDuration(doubleTapToZoomDuration, animations: {  [weak self] in

                self?.scrollView.setZoomScale(1.0, animated: false)
                })
        }
    }

    func scrollViewDidSwipeToDismiss(recognizer: UIPanGestureRecognizer) {

        /// a swipe gesture on image view that has no image (it was not yet loaded,so we see a spinner) doesn't make sense
        guard itemView.image != nil else {  return }

        /// A deliberate UX decision...you have to zoom back in to scale 1 to be able to swipe to dismiss. It is difficult for the user to swipe to dismiss from images larger then screen bounds because almost all the time it's not swiping to dismiss but instead panning a zoomed in picture on the canvas.
        guard scrollView.zoomScale == scrollView.minimumZoomScale else { return }

        let currentVelocity = recognizer.velocityInView(self.view)
        let currentTouchPoint = recognizer.translationInView(view)

        if swipingToDismiss == nil { swipingToDismiss = (fabs(currentVelocity.x) > fabs(currentVelocity.y)) ? .Horizontal : .Vertical }
        guard let swipingToDismissInProgress = swipingToDismiss else { return }

        //displacedView.hidden = false
        //dynamicTransparencyActive = true

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

    // MARK: - Swipe To Dismiss

    func handleSwipeToDismissInProgress(swipeOrientation: SwipeToDismiss, forTouchPoint touchPoint: CGPoint) {

        switch (swipeOrientation, index) {

        case (.Horizontal, 0) where self.itemCount != 1:

            /// edge case horizontal first index - limits the swipe to dismiss to HORIZONTAL RIGHT direction.
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: min(0, -touchPoint.x))

        case (.Horizontal, self.itemCount - 1) where self.itemCount != 1:

            /// edge case horizontal last index - limits the swipe to dismiss to HORIZONTAL LEFT direction.
            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: max(0, -touchPoint.x))

        case (.Horizontal, _):

            swipeToDismissTransition?.updateInteractiveTransition(horizontalOffset: -touchPoint.x) // all the rest

        case (.Vertical, _):

            swipeToDismissTransition?.updateInteractiveTransition(verticalOffset: -touchPoint.y) // all the rest
        }
    }

    func handleSwipeToDismissEnded(swipeOrientation: SwipeToDismiss, finalVelocity velocity: CGPoint, finalTouchPoint touchPoint: CGPoint) {

        let maxIndex = self.itemCount - 1

        let swipeToDismissCompletionBlock = { [weak self] in

            UIApplication.applicationWindow.windowLevel = UIWindowLevelNormal
            self?.swipingToDismiss = nil
            self?.delegate?.itemControllerDidFinishSwipeToDismissSuccesfully()
        }

        switch (swipeOrientation, index) {

        /// Any item VERTICAL UP direction
        case (.Vertical, _) where velocity.y < -thresholdVelocity:

            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation,
                                                                  touchPoint: touchPoint.y,
                                                                  targetOffset: (view.bounds.height / 2) + (itemView.bounds.height / 2),
                                                                  escapeVelocity: velocity.y,
                                                                  completion: swipeToDismissCompletionBlock)
        /// Any item VERTICAL DOWN direction
        case (.Vertical, _) where thresholdVelocity < velocity.y:

            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation,
                                                                  touchPoint: touchPoint.y,
                                                                  targetOffset: -(view.bounds.height / 2) - (itemView.bounds.height / 2),
                                                                  escapeVelocity: velocity.y,
                                                                  completion: swipeToDismissCompletionBlock)
        /// First item HORIZONTAL RIGHT direction
        case (.Horizontal, 0) where thresholdVelocity < velocity.x:

            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation,
                                                                  touchPoint: touchPoint.x,
                                                                  targetOffset: -(view.bounds.width / 2) - (itemView.bounds.width / 2),
                                                                  escapeVelocity: velocity.x,
                                                                  completion: swipeToDismissCompletionBlock)
        /// Last item HORIZONTAL LEFT direction
        case (.Horizontal, maxIndex) where velocity.x < -thresholdVelocity:

            swipeToDismissTransition?.finishInteractiveTransition(swipeOrientation,
                                                                  touchPoint: touchPoint.x,
                                                                  targetOffset: (view.bounds.width / 2) + (itemView.bounds.width / 2),
                                                                  escapeVelocity: velocity.x,
                                                                  completion: swipeToDismissCompletionBlock)

        ///If nonoe of the above select cases, we cancel.
        default:

            swipeToDismissTransition?.cancelTransition() { [weak self] in
                self?.swipingToDismiss = nil
            }
        }
    }

    func animateDisplacedImageToOriginalPosition(duration: NSTimeInterval, completion: ((Bool) -> Void)?) {

        guard (self.isAnimating == false) else { return }
        isAnimating = true

        UIView.animateWithDuration(duration, animations: {  [weak self] in

            self?.scrollView.zoomScale = self!.scrollView.minimumZoomScale

            if UIApplication.isPortraitOnly {
                self?.itemView.transform = CGAffineTransformInvert(rotationTransform())
            }

        }) { [weak self] finished in

            completion?(finished)

            if finished {

                UIApplication.applicationWindow.windowLevel = UIWindowLevelNormal

                self?.isAnimating = false
            }
        }
    }

    // MARK: - Present/Dismiss transitions

    func presentItem(alongsideAnimation alongsideAnimation: () -> Void, completion: () -> Void) {

        alongsideAnimation()

        switch presentationStyle {

        case .Fade:

            itemView.alpha = 0
            itemView.hidden = false

            UIView.animateWithDuration(itemFadeDuration, animations: { [weak self] in

                self?.itemView.alpha = 1

            }) { _ in

                completion()
            }

        case .Displacement:

            //Get the displaced view
            guard let displacedView = displacedViewsDatasource?.provideDisplacementItem(atIndex: index) as? UIImageView,
                let image = displacedView.image else { return }

            //Prepare the animated image view
            let animatedImageView = displacedView.clone()

            print(animatedImageView)

            UIDevice.currentDevice().orientation

            animatedImageView.frame = displacedView.frame(inCoordinatesOfView: self.view)
            animatedImageView.clipsToBounds = true
            self.view.addSubview(animatedImageView)

            displacedView.hidden = true

            UIView.animateWithDuration(displacementDuration, delay: 0, usingSpringWithDamping: displacementSpringBounce, initialSpringVelocity: 1, options: .CurveEaseIn, animations: { [weak self] in

                if UIApplication.isPortraitOnly == true {
                    animatedImageView.transform = rotationTransform()
                }
                /// Animate it into the center (with optionaly rotating) - that basically includes changing the size and position

                animatedImageView.bounds.size = self?.displacementTargetSize(forSize: image.size) ?? image.size
                animatedImageView.center = self?.view.boundsCenter ?? CGPoint.zero

                }, completion: { [weak self] done in

                    completion()

                    self?.itemView.hidden = false
                    displacedView.hidden = false
                    animatedImageView.removeFromSuperview()

                    self?.didFinishPresentingItem()
                })
        }
    }

    func displacementTargetSize(forSize size: CGSize) -> CGSize {

        let boundingSize = rotationAdjustedBounds().size

        return aspectFitSize(forContentOfSize: size, inBounds: boundingSize)
    }

    func didFinishPresentingItem() {

    }

    func findVisibleDisplacedView() -> UIImageView? {

        guard let displacedView = displacedViewsDatasource?.provideDisplacementItem(atIndex: index) as? UIImageView else { return nil }

        let displacedViewFrame = displacedView.frame(inCoordinatesOfView: self.view)
        let validAreaFrame = self.view.frame.insetBy(dx: displacedViewFrame.size.width * 0.8, dy: displacedViewFrame.size.height * 0.8)
        let isVisibleEnough = displacedViewFrame.intersects(validAreaFrame)

        return isVisibleEnough ? displacedView : nil
    }

    func dismissItem(alongsideAnimation alongsideAnimation: () -> Void, completion: () -> Void) {

        alongsideAnimation()

        switch presentationStyle {

        case .Displacement:

            if let displacedView = self.findVisibleDisplacedView() {

                UIView.animateWithDuration(reverseDisplacementDuration, animations: { [weak self] in

                    self?.itemView.frame = displacedView.frame(inCoordinatesOfView: self!.view)
                    self?.itemView.clipsToBounds = true
                    self?.itemView.contentMode = displacedView.contentMode

                    }, completion: { _ in

                        completion()
                })
            }

        case .Fade:

            UIView.animateWithDuration(itemFadeDuration, animations: {  [weak self] in

                self?.itemView.alpha = 0

            }) { _ in

                completion()
            }
        }
    }

    // MARK: - Arkane stuff

    ///This resolves which of the two pan gesture recognizers should kick in. There is one built in the OLDGalleryViewController (as it is a UIPageViewController subclass), and another one is added as part of item controller. When we pan, we need to decide whether it constitutes a horizontal paging gesture, or a swipe-to-dismiss gesture.
    /// All the logic is from the perspective of SwipeToDismissRecognizer - should it kick in (or let the paging recognizer page)?
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {

        /// We only care about the swipe to dismiss gesture recognizer, not the built-in pan recogizner that handles paging.
        guard gestureRecognizer == swipeToDismissRecognizer else { return false }

        /// The velocity vector will help us make the right decision
        let velocity = swipeToDismissRecognizer.velocityInView(swipeToDismissRecognizer.view)
        ///A bit of paranoia
        guard velocity.orientation != .None else { return false }

        /// We continue if the swipe is horizontal, otherwise it's Vertical and it is swipe to dismiss.
        guard velocity.orientation == .Horizontal else { return true }

        /// A special case for horizontal "swipe to dismiss" is when the gallery has carousel mode OFF, then it is possible to reach the beginning or the end of image set while paging. PAging will stop at index = 0 or at index.max. In this case we allow to jump out from the gallery also via horizontal swipe to dismiss.
        if (self.index == 0 && velocity.direction == .Right) || (self.index == self.itemCount - 1 && velocity.direction == .Left) {
            
            return (pagingMode == .Standard)
        }
        
        return false
    }
    
    //Reports the continuous progress of Swipe To Dismiss to the  Gallery View Controller
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let swipingToDissmissInProgress = swipingToDismiss else { return }
        guard keyPath == "contentOffset" else { return }
        
        let distanceToEdge: CGFloat
        let percentDistance: CGFloat
        
        switch swipingToDissmissInProgress {
            
        case .Horizontal:
            
            distanceToEdge = (scrollView.bounds.width / 2) + (itemView.bounds.width / 2)
            percentDistance = fabs(scrollView.contentOffset.x / distanceToEdge)
            
        case .Vertical:
            
            distanceToEdge = (scrollView.bounds.height / 2) + (itemView.bounds.height / 2)
            percentDistance = fabs(scrollView.contentOffset.y / distanceToEdge)
        }
        
        if let delegate = self.delegate {
            delegate.itemController(self, didSwipeToDismissWithDistanceToEdge: percentDistance)
        }
    }
}
