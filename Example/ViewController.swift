//
//  ViewController.swift
//  Example
//
//  Created by Rui Peres on 05/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var forestImageView: UIImageView!
    
    private var imagePreviewer: ImageViewer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showViewer(sender: UIView) {
        
        let poorManProvider = PoorManProvider()
        let galleryViewModel = GalleryViewModel(imageProvider: poorManProvider, imageCount: images.count, displacedView: sender,  displacedViewIndex: sender.tag)
        
        let headerFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 24))
        let headerView = CounterView(frame: headerFrame, currentIndex: sender.tag, count: images.count)


        let footerFrame = CGRect(origin: CGPoint.zero, size: CGSize(width: 200, height: 24))
        let footerView = CounterView(frame: footerFrame, currentIndex: sender.tag, count: images.count)

        
        galleryViewModel.landedPageAtIndexCompletion = {
            headerView.currentIndex = $0
            footerView.currentIndex = $0
        }
        
        let galleryViewController = GalleryViewController(viewModel: galleryViewModel)
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        self.presentImageGallery(galleryViewController)
    }
}

class PoorManProvider: ImageProvider {
    
    func provideImage(completion: UIImage? -> Void) {
        completion(UIImage(named: "image_big"))
    }
    
    func provideImage(atIndex index: Int, completion: UIImage? -> Void) {
        
        completion(images[index])
    }
}

let images = [
    UIImage(named: "0"),
    UIImage(named: "1"),
    UIImage(named: "2"),
    UIImage(named: "3"),
    UIImage(named: "4"),
    UIImage(named: "5"),
    UIImage(named: "6"),
    UIImage(named: "7")]
