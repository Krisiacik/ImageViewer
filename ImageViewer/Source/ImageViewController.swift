//
//  ImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    //UI
    private let scrollView = UIScrollView()
    private let screenshot: UIImage?
    private let imageView = UIImageView()
    var applicationWindow: UIWindow? {
        return UIApplication.sharedApplication().delegate?.window?.flatMap { $0 }
    }
    
    //MODEL & STATE
    let imageViewModel: GalleryImageViewModel
    let index: Int
    private var isPortraitOnly = false
    private let zoomDuration = 0.2
    
    //INTERACTIONS
    private let doubleTapRecognizer = UITapGestureRecognizer()
    
    init(screenshot:UIImage?, imageViewModel: GalleryImageViewModel, index: Int) {
        
        self.screenshot = screenshot
        self.imageViewModel = imageViewModel
        self.index = index
        
        super.init(nibName: nil, bundle: nil)
        
        configureImageView()
        configureScrollView()
        configureGestureRecognizers()
        createViewHierarchy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureImageView() {
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.backgroundColor = UIColor.yellowColor()
        
        if let screenshotImage = screenshot {
            updateImageAndContentSize(screenshotImage)
        }
        
        imageViewModel.fetchImage {[weak self] image in
            
            if let fullSizedImage = image {
                self?.updateImageAndContentSize(fullSizedImage)
            }
        }
    }
    
    func updateImageAndContentSize(image: UIImage) {

        scrollView.zoomScale = 1
        let aspectFitSize = aspectFitContentSize(forBoundingSize: UIScreen.mainScreen().bounds.size, contentSize: image.size)
        imageView.image = image
        imageView.frame.size = aspectFitSize
        self.scrollView.contentSize = aspectFitSize
        imageView.center = scrollView.boundsCenter
    }
    
    func configureScrollView() {
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.decelerationRate = 0.5
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = imageViewModel.size
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
    }
    
    func configureGestureRecognizers() {
        
        doubleTapRecognizer.addTarget(self, action: "scrollViewDidDoubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    func createViewHierarchy() {
        
        scrollView.addSubview(imageView)
        self.view.addSubview(scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = self.view.bounds
        imageView.center = scrollView.boundsCenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func scrollViewDidDoubleTap(recognizer: UITapGestureRecognizer) {
        
        let touchPoint = recognizer.locationOfTouch(0, inView: imageView)
        
        let aspectFillScale = aspectFillZoomScale(forBoundingSize: rotationAdjustedBounds().size, contentSize: imageView.bounds.size)
        
        if (scrollView.zoomScale == 1.0 || scrollView.zoomScale > aspectFillScale) {
            
            let zoomRectangle = zoomRect(ForScrollView: scrollView, scale: aspectFillScale, center: touchPoint)
            
            UIView.animateWithDuration(zoomDuration, animations: {
                
                self.scrollView.zoomToRect(zoomRectangle, animated: false)
            })
        }
        else  {
            UIView.animateWithDuration(zoomDuration, animations: {
                
                self.scrollView.setZoomScale(1.0, animated: false)
            })
        }
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {

        imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
    
    func rotationAdjustedBounds() -> CGRect {
        guard let window = applicationWindow else { return CGRectZero }
        guard isPortraitOnly else {
            return window.bounds
        }
        
        return (UIDevice.currentDevice().orientation.isLandscape) ? CGRect(origin: CGPointZero, size: window.bounds.size.inverted()): window.bounds
    }
}
