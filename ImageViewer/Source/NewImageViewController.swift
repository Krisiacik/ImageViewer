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
    var transitionProgress: Float = 0

    let imageView = UIImageView()

    init(index: Int, image: UIImage, configuration: GalleryConfiguration) {

        self.index = index
        self.imageView.image = image

        super.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .Custom
        self.addObserver(self, forKeyPath: "transitionProgress", options: NSKeyValueObservingOptions.New, context: nil)
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

    func presentItem(animateAlongsideView alongsideView: BlurView) {

        //Get the displaced view
        guard let displacedView = displacedViewsDatasource?.provideDisplacementItem(atIndex: index) as? UIImageView,
            let image = displacedView.image else { return }

        //Prepare the animated image view
        let animatedImageView = displacedView.clone()
        animatedImageView.frame = displacedView.frame(inCoordinatesOfView: self.view)
        animatedImageView.clipsToBounds = true
        self.view.addSubview(animatedImageView)

        displacedView.hidden = true

        UIView.animateWithDuration(10, animations: { () -> Void in


            if UIApplication.isPortraitOnly == true {
                animatedImageView.transform = rotationTransform()
            }
            /// Animate it into the center (with optionaly rotating) - that basically includes changing the size and position

            let boundingSize = rotationAdjustedBounds().size
            let aspectFitSize = aspectFitContentSize(forBoundingSize: boundingSize, contentSize: image.size)

            animatedImageView.bounds.size = aspectFitSize
            animatedImageView.center = self.view.boundsCenter

            alongsideView.blur = 1

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

        UIView.transitionWithView(self.view, duration: 0.3, options: UIViewAnimationOptions.CurveLinear, animations: {

            self.transitionProgress = 1
            
            }, completion: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("OBSERVED")
    }
    
    func scrubberValueChanged(scrubber: UISlider) {
        
        self.delegate?.itemController(self, didTransitionWithProgress: CGFloat( 1 - scrubber.value / 1000))
    }
}


