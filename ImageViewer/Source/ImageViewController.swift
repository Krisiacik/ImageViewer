//
//  ImageViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/02/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let screenshot: UIImage?
    let imageViewModel: GalleryImageViewModel
    let imageView = UIImageView()
    let index: Int
    
    init(screenshot:UIImage?, imageViewModel: GalleryImageViewModel, index: Int) {
        
        self.screenshot = screenshot
        self.imageViewModel = imageViewModel
        self.index = index
        
        super.init(nibName: nil, bundle: nil)
        
        configureImageView()
        configureScrollView()
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
        
        scrollView.backgroundColor = UIColor.greenColor()
        scrollView.delegate = self
        scrollView.decelerationRate = 0.5
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = imageViewModel.size
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
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
    
    func scrollViewDidZoom(scrollView: UIScrollView) {

        imageView.center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}
