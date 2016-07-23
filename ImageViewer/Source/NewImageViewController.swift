//
//  NewImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class NewImageViewController: UIViewController, ItemController {

    //UI
    var imageView = UIImageView()

    //DELEGATE / DATASOURCE
    var delegate: ItemControllerDelegate?
    var displacedViewsDatasource: GalleryDisplacedViewsDatasource?

    //STATE
    let index: Int
    var isInitialController = false
    let fetchImageBlock: FetchImage

    //CONFIGURATION
    private var presentationStyle = GalleryPresentationStyle.Displace
    private var displacementDuration: NSTimeInterval = 0.6
    private var displacementTimingCurve: UIViewAnimationCurve = .Linear
    private var displacementSpringBounce: CGFloat = 0.7
    private var overlayAccelerationFactor: CGFloat = 1



    init(index: Int, fetchImageBlock: FetchImage, configuration: GalleryConfiguration, isInitialController: Bool = false) {

        self.index = index
        self.fetchImageBlock = fetchImageBlock
        self.isInitialController = isInitialController

        for item in configuration {

            switch item {

            case .PresentationStyle(let style):             presentationStyle = style
            case .DisplacementDuration(let duration):       displacementDuration = duration
            case .DisplacementTimingCurve(let curve):       displacementTimingCurve = curve
            case .OverlayAccelerationFactor(let factor):    overlayAccelerationFactor = factor

            case .DisplacementTransitionStyle(let style):

            switch style {

                case .SpringBounce(let bounce):             displacementSpringBounce = bounce
                case .Normal:                               displacementSpringBounce = 1
                }

            default: break
            }
        }

        super.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .Custom

        let dismissRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        dismissRecognizer.numberOfTapsRequired = 1

        self.view.addGestureRecognizer(dismissRecognizer)

        self.imageView.hidden = isInitialController
    }

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchImageBlock { [weak self] image in

            if let image = image {

                self?.imageView.image = image
                self?.imageView.bounds.size = aspectFitContentSize(forBoundingSize: self!.view.bounds.size, contentSize: image.size)
                self?.imageView.center = self!.view.boundsCenter

                self?.view.addSubview(self!.imageView)
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func presentItem(alongsideAnimation alongsideAnimation: Duration -> Void) {

        alongsideAnimation(displacementDuration * Double(overlayAccelerationFactor))

        switch presentationStyle {

        case .FadeIn:

            imageView.alpha = 0
            imageView.hidden = false
            UIView.animateWithDuration(displacementDuration) { [weak self] in

                self?.imageView.alpha = 1
            }

        case .Displace:

            //Get the displaced view
            guard let displacedView = displacedViewsDatasource?.provideDisplacementItem(atIndex: index) as? UIImageView,
                let image = displacedView.image else { return }

            //Prepare the animated image view
            let animatedImageView = displacedView.clone()
            animatedImageView.frame = displacedView.frame(inCoordinatesOfView: self.view)
            animatedImageView.clipsToBounds = true
            self.view.addSubview(animatedImageView)

            displacedView.hidden = true

            UIView.animateWithDuration(displacementDuration, delay: 0, usingSpringWithDamping: displacementSpringBounce, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: {

                if UIApplication.isPortraitOnly == true {
                    animatedImageView.transform = rotationTransform()
                }
                /// Animate it into the center (with optionaly rotating) - that basically includes changing the size and position

                let boundingSize = rotationAdjustedBounds().size
                let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: image.size)

                animatedImageView.bounds.size = aspectFitSize
                animatedImageView.center = self.view.boundsCenter

                }, completion: { _ in

                    self.imageView.hidden = false
                    animatedImageView.removeFromSuperview()
            })
        }
    }
    
    func dismiss() {
        
        self.delegate?.dismiss()
    }
}


