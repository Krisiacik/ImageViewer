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

    let imageView = UIImageView()

    init(index: Int, image: UIImage, configuration: GalleryConfiguration) {

        self.index = index
        self.imageView.image = image

        super.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .Custom
    }

    @available (iOS, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.3)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        guard let delegate = self.delegate else { return }

        if delegate.itemControllerShouldPresentInitially(self) == true {
            animateWithDisplacement()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func animateWithDisplacement() {

        print("ANIMATE")

        //Get the displaced view
        guard let displacedView = displacedViewsDatasource?.provideDisplacementItem(atIndex: index) as? UIImageView,
            let image = displacedView.image else { return }

        //Prepare the animated image view
        let animatedImageView = displacedView.clone()
        animatedImageView.frame = displacedView.frame(inCoordinatesOfView: self.view)
        animatedImageView.clipsToBounds = true
        self.view.addSubview(animatedImageView)

        displacedView.hidden = true

        UIView.animateWithDuration(0.3, animations: { () -> Void in

            if UIApplication.isPortraitOnly == true {
                animatedImageView.transform = rotationTransform()
            }
            /// Animate it into the center (with optionaly rotating) - that basically includes changing the size and position

            let boundingSize = rotationAdjustedBounds().size
            let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: image.size)

            animatedImageView.bounds.size = aspectFitSize
            animatedImageView.center = self.view.boundsCenter

            }, completion: { [weak self] _ in

//                /// Unhide gallery views
//                if self?.decorationViewsHidden == false {
//
//                    UIView.animateWithDuration(0.2, animations: { [weak self] in
//                        self?.headerView?.alpha = 1.0
//                        self?.footerView?.alpha = 1.0
//                        self?.closeView?.alpha = 1.0
//                        })
//                }
            })

    }

    func scrubberValueChanged(scrubber: UISlider) {

        self.delegate?.itemController(self, didTransitionWithProgress: CGFloat( 1 - scrubber.value / 1000))
    }
}


