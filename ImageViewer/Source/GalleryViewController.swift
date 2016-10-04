//
//  GalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public class GalleryViewController: UIPageViewController, ItemControllerDelegate {

    //UI
    private let overlayView = BlurView()
    /// A custom view on the top of the gallery with layout using default (or custom) pinning settings for header.
    public var headerView: UIView?
    /// A custom view at the bottom of the gallery with layout using default (or custom) pinning settingsfor footer.
    public var footerView: UIView?
    private var closeButton: UIButton? = UIButton.closeButton()
    private var thumbnailsButton: UIButton? = UIButton.thumbnailsButton()
    private let scrubber = VideoScrubber()

    private weak var initialItemController: ItemController?

    ///LOCAL STATE
    ///represents the current page index, updated when the root view of the view controller representing the page stops animating inside visible bounds and stays on screen.
    var currentIndex: Int
    ///Picks up the initial value from configuration, if provided. Subseqently also works as local state for the setting.
    private var decorationViewsHidden = false
    private var isAnimating = false
    private var initialPresentationDone = false

    //DATASOURCE
    private let itemsDatasource: GalleryItemsDatasource
    private let pagingDatasource: GalleryPagingDatasource

    /// CONFIGURATION
    private var spineDividerWidth: Float = 10
    private var galleryPagingMode = GalleryPagingMode.Standard
    private var headerLayout = HeaderLayout.Center(25)
    private var footerLayout = FooterLayout.Center(25)
    private var closeLayout = ButtonLayout.PinRight(8, 16)
    private var thumbnailsLayout = ButtonLayout.PinLeft(8, 16)
    private var statusBarHidden = true
    private var overlayAccelerationFactor: CGFloat = 1
    private var rotationDuration = 0.15
    private var rotationMode = GalleryRotationMode.Always
    private let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6
    private var decorationViewsFadeDuration = 0.15

    /// COMPLETION BLOCKS
    /// If set ,the block is executed right after the initial launch animations finish.
    public var launchedCompletion: (() -> Void)?
    /// If set, called everytime ANY animation stops in the page controller stops and the viewer passes a page index of the page that is currently on screen
    public var landedPageAtIndexCompletion: ((Int) -> Void)?
    /// If set, launched after all animations finish when the close button is pressed.
    public var closedCompletion: (() -> Void)?
    /// If set, launched after all animations finish when the close() method is invoked via public API.
    public var programaticallyClosedCompletion: (() -> Void)?
    /// If set, launched after all animations finish when the swipe-to-dismiss (applies to all directions and cases) gesture is used.
    public var swipedToDismissCompletion: (() -> Void)?

    @available(*, unavailable)
    required public init?(coder: NSCoder) { fatalError() }

    public init(startIndex: Int, itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource? = nil, configuration: GalleryConfiguration = []) {

        self.currentIndex = startIndex
        self.itemsDatasource = itemsDatasource

        ///Only those options relevant to the paging GalleryViewController are explicitely handled here, the rest is handled by ItemViewControllers
        for item in configuration {

            switch item {

            case .ImageDividerWidth(let width):                 spineDividerWidth = Float(width)
            case .PagingMode(let mode):                         galleryPagingMode = mode
            case .HeaderViewLayout(let layout):                 headerLayout = layout
            case .FooterViewLayout(let layout):                 footerLayout = layout
            case .CloseLayout(let layout):                      closeLayout = layout
            case .ThumbnailsLayout(let layout):                 thumbnailsLayout = layout
            case .StatusBarHidden(let hidden):                  statusBarHidden = hidden
            case .HideDecorationViewsOnLaunch(let hidden):      decorationViewsHidden = hidden
            case .DecorationViewsFadeDuration(let duration):    decorationViewsFadeDuration = duration
            case .RotationDuration(let duration):               rotationDuration = duration
            case .RotationMode(let mode):                       rotationMode = mode
            case .OverlayColor(let color):                      overlayView.overlayColor = color
            case .OverlayBlurStyle(let style):                  overlayView.blurringView.effect = UIBlurEffect(style: style)
            case .OverlayBlurOpacity(let opacity):              overlayView.blurTargetOpacity = opacity
            case .OverlayColorOpacity(let opacity):             overlayView.colorTargetOpacity = opacity
            case .BlurPresentDuration(let duration):            overlayView.blurPresentDuration = duration
            case .BlurPresentDelay(let delay):                  overlayView.blurPresentDelay = delay
            case .ColorPresentDuration(let duration):           overlayView.colorPresentDuration = duration
            case .ColorPresentDelay(let delay):                 overlayView.colorPresentDelay = delay
            case .BlurDismissDuration(let duration):            overlayView.blurDismissDuration = duration
            case .BlurDismissDelay(let delay):                  overlayView.blurDismissDelay = delay
            case .ColorDismissDuration(let duration):           overlayView.colorDismissDuration = duration
            case .ColorDismissDelay(let delay):                 overlayView.colorDismissDelay = delay

            case .CloseButtonMode(let buttonMode):

                switch buttonMode {

                case .None:                 closeButton = nil
                case .Custom(let button):   closeButton = button
                case .BuiltIn:              break
                }
                
            case .ThumbnailsButtonMode(let buttonMode):
                
                switch buttonMode {
                    
                case .None:                 thumbnailsButton = nil
                case .Custom(let button):   thumbnailsButton = button
                case .BuiltIn:              break
                }

            default: break
            }
        }

        pagingDatasource = GalleryPagingDatasource(itemsDatasource: itemsDatasource, displacedViewsDatasource: displacedViewsDatasource, scrubber: scrubber, configuration: configuration)

        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll,
                   navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal,
                   options: [UIPageViewControllerOptionInterPageSpacingKey : NSNumber(float: spineDividerWidth)])

        pagingDatasource.itemControllerDelegate = self

        ///This feels out of place, one would expect even the first presented(paged) item controller to be provided by the paging datasource but there is nothing we can do as Apple requires the first controller to be set via this "setViewControllers" method.
        let initialController = pagingDatasource.createItemController(startIndex, isInitial: true)
        self.setViewControllers([initialController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

        if let controller = initialController as? ItemController {

            initialItemController = controller
        }

        ///This less known/used presentation style option allows the contents of parent view controller presenting the gallery to "bleed through" the blurView. Otherwise we would see only black color.
        self.modalPresentationStyle = .OverFullScreen
        self.dataSource = pagingDatasource

        UIApplication.applicationWindow.windowLevel = (statusBarHidden) ? UIWindowLevelStatusBar + 1 : UIWindowLevelNormal

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GalleryViewController.rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    deinit {

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    private func configureOverlayView() {

        overlayView.bounds.size = UIScreen.mainScreen().bounds.insetBy(dx: -UIScreen.mainScreen().bounds.width / 2, dy: -UIScreen.mainScreen().bounds.height / 2).size

        if let controller = self.presentingViewController {

            overlayView.center = controller.view.boundsCenter
            controller.view.addSubview(overlayView)
        }
    }

    private func configureHeaderView() {

        if let header = headerView {
            header.alpha = 0
            self.view.addSubview(header)
        }
    }

    private func configureFooterView() {

        if let footer = footerView {
            footer.alpha = 0
            self.view.addSubview(footer)
        }
    }

    private func configureCloseButton() {

        closeButton?.addTarget(self, action: #selector(GalleryViewController.closeInteractively), forControlEvents: .TouchUpInside)

        if let closeButton = closeButton {
            closeButton.alpha = 0
            self.view.addSubview(closeButton)
        }
    }

    private func configureThumbnailsButton() {
        
        thumbnailsButton?.addTarget(self, action: #selector(GalleryViewController.showThumbnails), forControlEvents: .TouchUpInside)
        
        if let thumbnailsButton = thumbnailsButton {
            thumbnailsButton.alpha = 0
            self.view.addSubview(thumbnailsButton)
        }
    }
    
    private func configureScrubber() {

        scrubber.alpha = 0
        self.view.addSubview(scrubber)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        configureHeaderView()
        configureFooterView()
        configureCloseButton()
        configureThumbnailsButton()
        configureScrubber()
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        guard initialPresentationDone == false else { return }
        
        ///We have to call this here (not sooner), because it adds the overlay view to the presenting controller and the presentingController property is set only at this moment in the VC lifecycle.
        configureOverlayView()

        ///The initial presentation animations and transitions
        presentInitially()
        
        initialPresentationDone = true
    }

    private func presentInitially() {

        isAnimating = true

        ///Animates decoration views to the initial state if they are set to be visible on launch. We do not need to do anything if they are set to be hidden because they are already set up as hidden by default. Unhiding them for the launch is part of chosen UX.
        initialItemController?.presentItem(alongsideAnimation: { [weak self] in

            self?.overlayView.present()

            }, completion: { [weak self] in

                if let weakself = self {

                    if weakself.decorationViewsHidden == false {

                        weakself.animateDecorationViews(visible: true)
                    }

                    weakself.isAnimating = false
                }
            })
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if rotationMode == .Always && UIApplication.isPortraitOnly {

            let transform = windowRotationTransform()
            let bounds = rotationAdjustedBounds()

            self.view.transform = transform
            self.view.bounds = bounds
        }

        overlayView.frame = view.bounds.insetBy(dx: -UIScreen.mainScreen().bounds.width * 2, dy: -UIScreen.mainScreen().bounds.height * 2)

        layoutButton(closeButton, layout: closeLayout)
        layoutButton(thumbnailsButton, layout: thumbnailsLayout)
        layoutHeaderView()
        layoutFooterView()
        layoutScrubber()
    }
    
    private func layoutButton(button: UIButton?, layout: ButtonLayout) {
        
        guard let button = button else { return }
        
        switch layout {
            
        case .PinRight(let marginTop, let marginRight):
            
            button.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
            button.frame.origin.x = self.view.bounds.size.width - marginRight - button.bounds.size.width
            button.frame.origin.y = marginTop
            
        case .PinLeft(let marginTop, let marginLeft):
            
            button.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
            button.frame.origin.x = marginLeft
            button.frame.origin.y = marginTop
        }
    }

    private func layoutHeaderView() {

        guard let header = headerView else { return }

        switch headerLayout {

        case .Center(let marginTop):

            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
            header.center = self.view.boundsCenter
            header.frame.origin.y = marginTop

        case .PinBoth(let marginTop, let marginLeft,let marginRight):

            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleWidth]
            header.bounds.size.width = self.view.bounds.width - marginLeft - marginRight
            header.sizeToFit()
            header.frame.origin = CGPoint(x: marginLeft, y: marginTop)

        case .PinLeft(let marginTop, let marginLeft):

            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
            header.frame.origin = CGPoint(x: marginLeft, y: marginTop)

        case .PinRight(let marginTop, let marginRight):

            header.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
            header.frame.origin = CGPoint(x: self.view.bounds.width - marginRight - header.bounds.width, y: marginTop)
        }
    }

    private func layoutFooterView() {

        guard let footer = footerView else { return }

        switch footerLayout {

        case .Center(let marginBottom):

            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin]
            footer.center = self.view.boundsCenter
            footer.frame.origin.y = self.view.bounds.height - footer.bounds.height - marginBottom

        case .PinBoth(let marginBottom, let marginLeft,let marginRight):

            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleWidth]
            footer.frame.size.width = self.view.bounds.width - marginLeft - marginRight
            footer.sizeToFit()
            footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.bounds.height - marginBottom)

        case .PinLeft(let marginBottom, let marginLeft):

            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleRightMargin]
            footer.frame.origin = CGPoint(x: marginLeft, y: self.view.bounds.height - footer.bounds.height - marginBottom)

        case .PinRight(let marginBottom, let marginRight):

            footer.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin]
            footer.frame.origin = CGPoint(x: self.view.bounds.width - marginRight - footer.bounds.width, y: self.view.bounds.height - footer.bounds.height - marginBottom)
        }
    }

    private func layoutScrubber() {

        scrubber.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.width, height: 40))
        scrubber.center = self.view.boundsCenter
        scrubber.frame.origin.y = (footerView?.frame.origin.y ?? self.view.bounds.maxY) - scrubber.bounds.height
    }
    
    //Thumbnails
    
    @objc private func showThumbnails() {
        
        let thumbnailsController = ThumbnailsViewController(itemsDatasource: self.itemsDatasource)
        
        if let closeButton = closeButton {
            let seeAllCloseButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: closeButton.bounds.size))
            seeAllCloseButton.setImage(closeButton.imageForState(.Normal), forState: .Normal)
            seeAllCloseButton.setImage(closeButton.imageForState(.Highlighted), forState: .Highlighted)
            thumbnailsController.closeButton = seeAllCloseButton
            thumbnailsController.closeLayout = closeLayout
        }
        thumbnailsController.onItemSelected = { [weak self] index in

            self?.page(toIndex: index)
        }

        presentViewController(thumbnailsController, animated: true, completion: nil)
    }
    
    public func page(toIndex index: Int) {
        
        guard currentIndex != index && index >= 0 && index < self.itemsDatasource.itemCount() else { return }
        
        let imageViewController = self.pagingDatasource.createItemController(index)
        let direction: UIPageViewControllerNavigationDirection = index > currentIndex ? .Forward : .Reverse
        
        // workaround to make UIPageViewController happy
        if direction == .Forward {
            let previousVC = self.pagingDatasource.createItemController(index - 1)
            setViewControllers([previousVC], direction: direction, animated: true, completion: { finished in
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.setViewControllers([imageViewController], direction: direction, animated: false, completion: nil)
                    })
            })
        } else {
            let nextVC = self.pagingDatasource.createItemController(index + 1)
            setViewControllers([nextVC], direction: direction, animated: true, completion: { finished in
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.setViewControllers([imageViewController], direction: direction, animated: false, completion: nil)
                    })
            })
        }
    }

    // MARK: - Animations

    @objc private func rotate() {

        /// If the app supports rotation on global level, we don't need to rotate here manually because the rotation
        /// of key Window will rotate all app's content with it via affine transform and from the perspective of the
        /// gallery it is just a simple relayout. Allowing access to remaining code only makes sense if the app is
        /// portrait only but we still want to support rotation inside the gallery.
        guard UIApplication.isPortraitOnly else { return }

        guard UIDevice.currentDevice().orientation.isFlat == false &&
            isAnimating == false else { return }

        isAnimating = true

        UIView.animateWithDuration(rotationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self] () -> Void in

            self?.view.transform = windowRotationTransform()
            self?.view.bounds = rotationAdjustedBounds()
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()

            })
        { [weak self] finished  in

            self?.isAnimating = false
        }
    }

    /// Invoked when closed programatically
    public func close() {

        closeDecorationViews(programaticallyClosedCompletion)
    }

    /// Invoked when closed via close button
    @objc private func closeInteractively() {

        closeDecorationViews(closedCompletion)
    }

    private func closeDecorationViews(completion: (() -> Void)?) {

        guard isAnimating == false else { return }
        isAnimating = true

        if let itemController = self.viewControllers?.first as? ItemController {

            itemController.closeDecorationViews?(decorationViewsFadeDuration)
        }

        UIView.animateWithDuration(decorationViewsFadeDuration, animations: { [weak self] in

            self?.headerView?.alpha = 0.0
            self?.footerView?.alpha = 0.0
            self?.closeButton?.alpha = 0.0
            self?.thumbnailsButton?.alpha = 0.0
            self?.scrubber.alpha = 0.0

            }, completion: { [weak self] done in

                if let weakself = self,
                    let itemController = weakself.viewControllers?.first as? ItemController {

                    itemController.dismissItem(alongsideAnimation: {

                        weakself.overlayView.dismiss()

                        }, completion: { [weak self] in

                            self?.isAnimating = true
                            self?.closeGallery(false, completion: completion)
                    })
                }
            })
    }

    func closeGallery(animated: Bool, completion: (() -> Void)?) {

        self.overlayView.removeFromSuperview()

        self.modalTransitionStyle = .CrossDissolve

        self.dismissViewControllerAnimated(animated) {

            UIApplication.applicationWindow.windowLevel = UIWindowLevelNormal
            completion?()
        }
    }

    private func animateDecorationViews(visible visible: Bool) {

        let targetAlpha: CGFloat = (visible) ? 1 : 0

        UIView.animateWithDuration(decorationViewsFadeDuration) { [weak self] in

            self?.headerView?.alpha = targetAlpha
            self?.footerView?.alpha = targetAlpha
            self?.closeButton?.alpha = targetAlpha
            self?.thumbnailsButton?.alpha = targetAlpha
            
            if let _ = self?.viewControllers?.first as? VideoViewController {

                UIView.animateWithDuration(0.3) { [weak self] in

                    self?.scrubber.alpha = targetAlpha
                }
            }
        }
    }

    func itemControllerWillAppear(controller: ItemController) {

        if let videoController = controller as? VideoViewController {

            scrubber.player = videoController.player
        }
    }

    func itemControllerWillDisappear(controller: ItemController) {

        if let _ = controller as? VideoViewController {

            scrubber.player = nil

            UIView.animateWithDuration(0.3) { [weak self] in

                self?.scrubber.alpha = 0
            }
        }
    }

    func itemControllerDidAppear(controller: ItemController) {

        self.currentIndex = controller.index
        self.landedPageAtIndexCompletion?(self.currentIndex)
        self.headerView?.sizeToFit()
        self.footerView?.sizeToFit()
        
        if let _ = controller as? VideoViewController {
            
            if scrubber.alpha == 0 && decorationViewsHidden == false {
                
                UIView.animateWithDuration(0.3) { [weak self] in
                    
                    self?.scrubber.alpha = 1
                }
            }
        }
    }
    
    func itemControllerDidSingleTap(controller: ItemController) {
        
        self.decorationViewsHidden.flip()
        animateDecorationViews(visible: !self.decorationViewsHidden)
    }
    
    func itemController(controller: ItemController, didSwipeToDismissWithDistanceToEdge distance: CGFloat) {
        
        if decorationViewsHidden == false {
            
            let alpha = 1 - distance * swipeToDismissFadeOutAccelerationFactor
            
            closeButton?.alpha = alpha
            thumbnailsButton?.alpha = alpha
            headerView?.alpha = alpha
            footerView?.alpha = alpha

            if controller is VideoViewController {
                scrubber.alpha = alpha
            }
        }
        
        self.overlayView.blurringView.alpha = 1 - distance
        self.overlayView.colorView.alpha = 1 - distance
    }
    
    func itemControllerDidFinishSwipeToDismissSuccesfully() {
        
        self.swipedToDismissCompletion?()
        self.overlayView.removeFromSuperview()
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
