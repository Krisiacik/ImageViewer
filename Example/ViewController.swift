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
        
        guard let view = sender as? UIView else { return }
        
        let provider = PoorManProvider()
        
        let size = CGSize(width: 1920, height: 1080)
        
        let buttonsAssets = ButtonStateAssets(normalAsset: UIImage(named: "close_normal")!, highlightedAsset: UIImage(named: "close_highlighted")!)
        
        let configuration = ImageViewerConfiguration(imageSize: size, closeButtonAssets: buttonsAssets)
        self.imagePreviewer = ImageViewer(imageProvider: provider, configuration: configuration, displacedView: view)
        self.presentImageViewer(self.imagePreviewer)
    }
}

