//
//  NewGalleryViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public class NewGalleryViewController: UIPageViewController {

    //VIEWS
    private let blurView = BlurView()
    private var closeButton: UIButton? = makeCloseButton()

    ///LOCAL STATE
    private var decorationViewsHidden = true ///Picks up the initial value from configuration, if provided. Subseqently also works as local state for the setting.

    //PAGING DATASOURCE
    private let pagingDatasource: NewGalleryPagingDatasource

    /// CONFIGURATION
    private var spineDividerWidth: Float = 10
    private var galleryPagingMode = GalleryPagingMode.Standard
    private var headerLayout = HeaderLayout.Center(25)
    private var footerLayout = FooterLayout.Center(25)
    private var closeLayout = CloseButtonLayout.PinRight(8, 16)
    private var statusBarHidden = true

    @available(*, unavailable)
    required public init?(coder: NSCoder) { fatalError() }

    init(startIndex: Int, itemsDatasource: GalleryItemsDatasource, displacedViewsDatasource: GalleryDisplacedViewsDatasource? = nil, configuration: GalleryConfiguration = []) {

        ///Only those options relevant to the paging GalleryViewController are handled here explicitely, the rest are handled by the GalleryItemController
        for item in configuration {

            switch item {

            case .ImageDividerWidth(let width):             spineDividerWidth = Float(width)
            case .PagingMode(let mode):                     galleryPagingMode = mode
            case .HeaderViewLayout(let layout):             headerLayout = layout
            case .FooterViewLayout(let layout):             footerLayout = layout
            case .CloseLayout(let layout):                  closeLayout = layout
            case .StatusBarHidden(let hidden):              statusBarHidden = hidden
            case .HideDecorationViewsOnLaunch(let hidden):  decorationViewsHidden = hidden

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

        ///This feels out of place, one would expect even the first presented(paged) item controller to be provided by the paging datasource but there is nothing we can do as Apple requires the first controller to be set via this "setViewControllers" method.
        let initialImageController = pagingDatasource.createItemController(startIndex)
        self.setViewControllers([initialImageController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

        self.modalPresentationStyle = .OverFullScreen ///This less usual option allows the contents of view controller that presents the gallery to "bleed through" the blurView. CHECK IF REALLY NEEDED!!!!!
        self.dataSource = pagingDatasource
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurView)
        view.sendSubviewToBack(blurView)

    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        blurView.frame = view.bounds
    }
}
