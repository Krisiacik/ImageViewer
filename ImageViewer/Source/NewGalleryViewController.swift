//
//  NewGalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public class NewGalleryViewController: UIPageViewController, ItemControllerDelegate {

    //UI
    private let overlayView = BlurView()
    /// A custom view on the top of the gallery with layout using default (or custom) pinning settings for header.
    public var headerView: UIView?
    /// A custom view at the bottom of the gallery with layout using default (or custom) pinning settingsfor footer.
    public var footerView: UIView?
    private var closeButton: UIButton? = makeCloseButton()
    
    private weak var initialItemController: ItemController?
    
    private var initialPresentationDone = false

    ///LOCAL STATE
    ///represents the current page index
    var currentIndex: Int
    ///Picks up the initial value from configuration, if provided. Subseqently also works as local state for the setting.
    private var decorationViewsHidden = true
    private var isAnimating = false

    //PAGING DATASOURCE
    private let pagingDatasource: NewGalleryPagingDatasource

    /// CONFIGURATION
    private var spineDividerWidth: Float = 10
    private var galleryPagingMode = GalleryPagingMode.Standard
    private var headerLayout = HeaderLayout.Center(25)
    private var footerLayout = FooterLayout.Center(25)
    private var closeLayout = CloseButtonLayout.PinRight(8, 16)
    private var statusBarHidden = true
    private var overlayAccelerationFactor: CGFloat = 1
    private let rotationAnimationDuration = 0.2
    private let swipeToDismissFadeOutAccelerationFactor: CGFloat = 6
    private let decorationViewsVisibilityAnimationDuration = 0.15
    
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

    init(startIndex: Int, itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource? = nil, configuration: GalleryConfiguration = []) {

        self.currentIndex = startIndex
        
        ///Only those options relevant to the paging GalleryViewController are explicitely handled here, the rest is handled by ItemViewControllers
        for item in configuration {

            switch item {

            case .ImageDividerWidth(let width):             spineDividerWidth = Float(width)
            case .PagingMode(let mode):                     galleryPagingMode = mode
            case .HeaderViewLayout(let layout):             headerLayout = layout
            case .FooterViewLayout(let layout):             footerLayout = layout
            case .CloseLayout(let layout):                  closeLayout = layout
            case .StatusBarHidden(let hidden):              statusBarHidden = hidden
            case .HideDecorationViewsOnLaunch(let hidden):  decorationViewsHidden = hidden
            case .OverlayColor(let color):                  overlayView.overlayColor = color
            case .OverlayBlurStyle(let style):              overlayView.blurringView.effect = UIBlurEffect(style: style)
            case .OverlayBlurOpacity(let opacity):          overlayView.blurOpacity = opacity
            case .OverlayColorOpacity(let opacity):         overlayView.colorOpacity = opacity


            case .CloseButtonMode(let closeButtonMode):

                switch closeButtonMode {

                case .None:                 closeButton = nil
                case .Custom(let button):   closeButton = button
                case .BuiltIn:              break
                }

            default: break
            }
        }

        pagingDatasource = NewGalleryPagingDatasource(itemsDatasource: itemsDatasource, displacedViewsDatasource: displacedViewsDatasource, configuration: configuration)

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

        ///This less known and used presentation style option allows the contents of parent view controller presenting the gallery to "bleed through" the blurView. Otherwise we would see only black color.
        self.modalPresentationStyle = .OverFullScreen
        self.dataSource = pagingDatasource

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GalleryViewController.rotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func configureHeaderView() {
        
        if let header = headerView {
            header.alpha = 0
            self.view.addSubview(header)
        }
    }
    
    func configureFooterView() {
        
        if let footer = footerView {
            footer.alpha = 0
            self.view.addSubview(footer)
        }
    }
    
    func configureCloseButton() {
        
        closeButton?.addTarget(self, action: #selector(GalleryViewController.closeInteractively), forControlEvents: .TouchUpInside)
        
        if let closeButton = closeButton {
            closeButton.alpha = 0
            self.view.addSubview(closeButton)
        }
    }
    
    func createViewHierarchy() {
        
        view.addSubview(overlayView)
        view.sendSubviewToBack(overlayView)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        configureHeaderView()
        configureFooterView()
        configureCloseButton()
        createViewHierarchy()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if decorationViewsHidden == false { animateDecorationViews(visible: true) }
        initialItemController?.presentItem(alongsideAnimation: overlayView.animate)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        overlayView.frame = view.bounds
        
        layoutCloseButton()
        layoutHeaderView()
        layoutFooterView()
    }

    func layoutCloseButton() {
        
        guard let close = closeButton else { return }
        
        switch closeLayout {
            
        case .PinRight(let marginTop, let marginRight):
            
            close.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin]
            close.frame.origin.x = self.view.bounds.size.width - marginRight - close.bounds.size.width
            close.frame.origin.y = marginTop
            
        case .PinLeft(let marginTop, let marginLeft):
            
            close.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin]
            close.frame.origin.x = marginLeft
            close.frame.origin.y = marginTop
        }
    }
    
    func layoutHeaderView() {
        
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
    
    func layoutFooterView() {
        
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

    // MARK: - Animations

    func rotate() {

        /// If the app supports rotation on global level, we don't need to rotate here manually because the rotation
        /// of key Window will rotate all app's content with it via affine transform and from the perspective of the
        /// gallery it is just a simple relayout. Allowing access to remaining code only makes sense if the app is
        /// portrait only but we still want to support rotation inside the gallery.
        guard isPortraitOnly() else { return }

        guard UIDevice.currentDevice().orientation.isFlat == false &&
            isAnimating == false else { return }

        isAnimating = true

        UIView.animateWithDuration(rotationAnimationDuration, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self] () -> Void in

            self?.view.transform = rotationTransform()
            self?.view.bounds = rotationAdjustedBounds()
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
            
            })
        { [weak self] finished  in
            
            self?.isAnimating = false
        }
    }
    
    func animateDecorationViews(visible visible: Bool) {
        
        let targetAlpha: CGFloat = (visible) ? 1 : 0
        
        UIView.animateWithDuration(decorationViewsVisibilityAnimationDuration) { [weak self] in
            
            self?.headerView?.alpha = targetAlpha
            self?.footerView?.alpha = targetAlpha
            self?.closeButton?.alpha = targetAlpha
        }
    }

    func itemControllerDidAppear(controller: ItemController) {
        
        self.currentIndex = controller.index
        self.landedPageAtIndexCompletion?(self.currentIndex)
        self.headerView?.sizeToFit()
        self.footerView?.sizeToFit()
    }
    
    func itemControllerDidSingleTap(controller: ItemController) {
        
        self.decorationViewsHidden.flip()
        animateDecorationViews(visible: !self.decorationViewsHidden)

    }
    
    func itemController(controller: ItemController, didSwipeToDismissWithDistanceToEdge distance: CGFloat) {
        
        if decorationViewsHidden == false {
            
            let alpha = 1 - distance * swipeToDismissFadeOutAccelerationFactor
            
            closeButton?.alpha = alpha
            headerView?.alpha = alpha
            footerView?.alpha = alpha
        }
    }
}
