//
//  ViewController.swift
//  Example
//
//  Created by Rui Peres on 05/12/2015.
//  Copyright © 2015 MailOnline. All rights reserved.
//

import UIKit

let images = [
    UIImage(named: "0"),
    UIImage(named: "1"),
    UIImage(named: "2"),
    UIImage(named: "3"),
    UIImage(named: "4"),
    UIImage(named: "5"),
    UIImage(named: "6"),
    UIImage(named: "7")]

class GalleryItemProvider: GalleryDatasource {
    
    func startingIndex() -> Int {
        return 0
    }
    
    func numberOfItemsInGalery() -> Int {
        
        return images.count
    }
    
    func provideDisplacementItem(atIndex index: Int, completion: UIImageView? -> Void) {
        
        completion(nil)
    }
    
    func provideGalleryItem(atIndex index: Int, completion: GalleryItem -> Void) {
        
        completion(GalleryItem.Image(images[index]!))
    }
}

class ViewController: UIViewController {
    
    @IBOutlet weak var forestImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showGalleryImageViewer(displacedView: UIView) {
        
        let imageProvider = GalleryItemProvider()
        
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let headerView = CounterView(frame: frame, currentIndex: displacedView.tag, count: images.count)
        let footerView = CounterView(frame: frame, currentIndex: displacedView.tag, count: images.count)
        
        let galleryViewController = GalleryViewController(datasource: imageProvider)
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

