//
//  NewGalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public class NewGalleryViewController: UIPageViewController, ItemControllerDelegate {

    //VIEWS
    private let blurView = BlurView()
    private var closeButton: UIButton? = makeCloseButton()
    private weak var initialItemController: ItemController?
    private var initialPresentationDone = false

    ///LOCAL STATE
    private var decorationViewsHidden = true ///Picks up the initial value from configuration, if provided. Subseqently also works as local state for the setting.
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

    @available(*, unavailable)
    required public init?(coder: NSCoder) { fatalError() }

    init(startIndex: Int, itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource? = nil, configuration: GalleryConfiguration = []) {

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
            case .OverlayColor(let color):                  blurView.overlayColor = color
            case .OverlayBlurStyle(let style):              blurView.blurringView.effect = UIBlurEffect(style: style)
            case .OverlayBlurOpacity(let opacity):          blurView.blurOpacity = opacity
            case .OverlayColorOpacity(let opacity):         blurView.colorOpacity = opacity


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

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        blurView.frame = view.bounds
    }

    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        initialItemController?.presentItem(alongsideAnimation: blurView.animate)
    }

    func itemController(controller: ItemController, didTransitionWithProgress progress: CGFloat) {

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
    
    func itemControllerDidSingleTap() {
        //HIDE DECORATION VIEWS HERE
        
        print("SINGLE TAP")
        self.presentingViewController?.view.subviews.forEach { $0.hidden = false }
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
