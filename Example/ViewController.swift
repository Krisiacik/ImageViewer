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
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    @IBAction func showViewer(sender: UIView) {
        
        let poorManProvider = PoorManProvider()
        let galleryViewModel = GalleryViewModel(imageProvider: poorManProvider, imageCount: 8, displacedView: sender,  displacedViewIndex: sender.tag)
        let galleryViewController = GalleryViewController(viewModel: galleryViewModel)
        self.presentImageGallery(galleryViewController)
    }
}


class PoorManProvider: ImageProvider {
    
    func provideImage(completion: UIImage? -> Void) {
        completion(UIImage(named: "image_big"))
    }
    
    func provideImage(atIndex index: Int, completion: UIImage? -> Void) {
        
        let images = [
            UIImage(named: "1"),
            UIImage(named: "2"),
            UIImage(named: "3"),
            UIImage(named: "4"),
            UIImage(named: "5"),
            UIImage(named: "6"),
            UIImage(named: "7"),
            UIImage(named: "8")]
        
        completion(images[index])
    }
}
