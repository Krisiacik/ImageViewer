//
//  NewImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 15/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class NewImageViewController: UIViewController, ItemController {

    let index: Int
    var delegate: ItemControllerDelegate?
    var displacedViewsDatasource: GalleryDisplacedViewsDatasource?
    var isInitialController = false

    //CONFIGURATION
    private var displacementDuration: NSTimeInterval = 0.6
    private var displacementTransitionCurve: UIViewAnimationCurve = .Linear
    private var displacementSpringBounce: CGFloat = 0.7
    private var overlayAccelerationFactor: CGFloat = 1

    let imageView = UIImageView()

    init(index: Int, image: UIImage, configuration: GalleryConfiguration) {

        self.index = index
        self.imageView.image = image

        for item in configuration {

            switch item {

            case .DisplacementDuration(let duration):       displacementDuration = duration
            case .DisplacementTransitionCurve(let curve):   displacementTransitionCurve = curve
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
    }

    @available (*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
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

        //Get the displaced view
        guard let displacedView = displacedViewsDatasource?.provideDisplacementItem(atIndex: index) as? UIImageView,
            let image = displacedView.image else { return }

        //Prepare the animated image view
        let animatedImageView = displacedView.clone()
        animatedImageView.frame = displacedView.frame(inCoordinatesOfView: self.view)
        animatedImageView.clipsToBounds = true
        self.view.addSubview(animatedImageView)

        displacedView.hidden = true

        alongsideAnimation(displacementDuration * Double(overlayAccelerationFactor))

        UIView.animateWithDuration(displacementDuration, delay: 0, usingSpringWithDamping: displacementSpringBounce, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseIn, animations: {

            if UIApplication.isPortraitOnly == true {
                animatedImageView.transform = rotationTransform()
            }
            /// Animate it into the center (with optionaly rotating) - that basically includes changing the size and position

            let boundingSize = rotationAdjustedBounds().size
            let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: image.size)

            animatedImageView.bounds.size = aspectFitSize
            animatedImageView.center = self.view.boundsCenter

            }, completion: nil)
    }
    
    func dismiss() {
        
        self.delegate?.dismiss()
    }
}


