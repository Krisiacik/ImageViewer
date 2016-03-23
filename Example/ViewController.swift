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
    

    @IBAction func showSingleImageViewer(sender: UIButton) {
        
        let poorManProvider = PoorManProvider()
        let buttonAssets = CloseButtonAssets(normal: UIImage(named:"close_normal")!, highlighted: UIImage(named: "close_highlighted"))
        let configuration = ImageViewerConfiguration(imageSize: CGSize(width: 10, height: 10), closeButtonAssets: buttonAssets)
        
        let imageViewer = ImageViewer(imageProvider: poorManProvider, configuration: configuration, displacedView: sender)
        
        self.presentImageViewer(imageViewer)
    }

    
    @IBAction func showViewer(sender: UIView) {
        
        let poorManProvider = PoorManProvider()
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: sender.tag, count: images.count)
        let footerView = CounterView(frame: frame, currentIndex: sender.tag, count: images.count)
        
        let galleryViewController = GalleryViewController(imageProvider: poorManProvider, displacedView: sender, imageCount: images.count, startIndex: sender.tag)
        galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }

        galleryViewController.landedPageAtIndexCompletion = { index in
            
            print("LANDED AT INDEX: \(index)")
            
            headerView.currentIndex = index
            footerView.currentIndex = index
        }
        
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
