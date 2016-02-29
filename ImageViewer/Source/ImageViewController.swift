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
        
        imageView.image = image
        let aspectFitSize = aspectFitContentSize(forBoundingSize: UIScreen.mainScreen().bounds.size, contentSize: image.size)
        imageView.frame.size = aspectFitSize
        self.scrollView.contentSize = aspectFitSize
        imageView.center = scrollView.boundsCenter
    }
    
    func configureScrollView() {
        
        scrollView.delegate = self
        scrollView.decelerationRate = 0.5
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = imageViewModel.size
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 12
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
        
        let center = contentCenter(forBoundingSize: scrollView.bounds.size, contentSize: scrollView.contentSize)
        
        imageView.center = center
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}

// MARK: - Utility

private func contentCenter(forBoundingSize boundingSize: CGSize, contentSize: CGSize) -> CGPoint {
    
    // When the zoom scale changes i.e. the image is zoomed in or out, the hypothetical center
    // of content view changes too. But the default Apple implementation is keeping the last center
    // value which doesn't make much sense. If the image ratio is not matching the screen
    // ratio, there will be some empty space horizontaly or verticaly. This needs to be calculated
    // so that we can get the correct new center value. When these are added, edges of contentView
    // are aligned in realtime and always aligned with corners of scrollview.
    
    let horizontalOffest = (boundingSize.width > contentSize.width) ? ((boundingSize.width - contentSize.width) * 0.5): 0.0
    let verticalOffset = (boundingSize.height > contentSize.height) ? ((boundingSize.height - contentSize.height) * 0.5): 0.0
    
    return CGPoint(x: contentSize.width * 0.5 + horizontalOffest,  y: contentSize.height * 0.5 + verticalOffset)
}
