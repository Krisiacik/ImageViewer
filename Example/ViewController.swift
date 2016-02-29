//
//  ViewController.swift
//  Example
//
//  Created by Rui Peres on 05/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

class PoorManProvider: ImageProvider {
    
    func provideImage(completion: UIImage? -> Void) {
        completion(UIImage(named: "image_big"))
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var forestImageView: UIImageView!
    
    private var imagePreviewer: ImageViewer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    @IBAction func showViewer(sender: AnyObject) {
        
        let screenShotImage = UIImage(named: "1small")
        let fullSizedImageURL = NSURL(string: "http://buzzerg.com/wp-content/uploads/8589130426979-fresh-and-natural-beauty-of-wallpaper-hd.jpg")!
        
        let imageViewModel = MyGalleryImageViewModel(url: fullSizedImageURL, size: CGSize(width: 320, height: 200))
        let imageController = ImageViewController(screenshot: screenShotImage, imageViewModel: imageViewModel, index: 0)
        
        let appDelegate = UIApplication.sharedApplication().delegate
        let navController = appDelegate?.window??.rootViewController
        
        navController?.presentViewController(imageController, animated: false, completion: nil)
        
        //        guard let view = sender as? UIView else { return }
        //
        //        let provider = PoorManProvider()
        //
        //        let size = CGSize(width: 1920, height: 1080)
        //
        //        let buttonsAssets = CloseButtonAssets(normal: UIImage(named: "close_normal")!, highlighted: UIImage(named: "close_highlighted")!)
        //
        //        let configuration = ImageViewerConfiguration(imageSize: size, closeButtonAssets: buttonsAssets)
        //        self.imagePreviewer = ImageViewer(imageProvider: provider, configuration: configuration, displacedView: view)
        //        self.presentImageViewer(self.imagePreviewer)
    }
}


class MyGalleryImageViewModel: GalleryImageViewModel {
    
    var url: NSURL
    var size: CGSize
    
    init(url: NSURL, size: CGSize) {
        
        self.url = url
        self.size = size
    }
    
    func fetchImage(completion: UIImage? -> Void) {
        
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        
        dispatch_async(backgroundQueue) {
            
            sleep(3) //simulating fetching the image at London Bridge from another continent
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                //this would idealy fetch from web url or image cache...for the moment let's hardcode the output..
                let image = UIImage(named: "1")
                
                completion(image)
            }
        }
    }
}

//class MyGalleryViewModel: GalleryViewModel {
//
//    var imageViewModels: GalleryImageViewModel
//    var headerView: UIView?
//    var footerView: UIView?
//    var reloadView: UIView?
//
//    init(imageViewModels: GalleryImageViewModel) {
//        self.imageViewModels = imageViewModels
//    }
//}

