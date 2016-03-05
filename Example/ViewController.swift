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
        let galleryViewModel = GalleryViewModel(imageProvider: poorManProvider, imageCount: 7, displacedView: sender,  displacedViewIndex: sender.tag)
        
        galleryViewModel.landedPageAtIndexCompletion = { index in
            
            print("LANDED AT: \(index)")
        }

        galleryViewModel.changedPageToIndexCompletion = { index in
            
            print("CHANGED PAGE TO: \(index)")
        }
        
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
            UIImage(named: "0"),
            UIImage(named: "1"),
            UIImage(named: "2"),
            UIImage(named: "3"),
            UIImage(named: "4"),
            UIImage(named: "5"),
            UIImage(named: "6"),
            UIImage(named: "7")]
        
        completion(images[index])
    }
}
