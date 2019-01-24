//
//  LivePhotoViewController.swift
//  ImageViewer
//
//  Created by Marcel Dittmann on 24.01.19.
//  Copyright © 2019 MailOnline. All rights reserved.
//

import UIKit

@available(iOS 9.1, *)
class LivePhotoViewController: ItemBaseController<LivePhotoView> {
    
    var fetchLivePhotoBlock: FetchLivePhotoBlock
    var image: UIImage?
    
    init(index: Int, itemCount: Int, fetchImageBlock: @escaping FetchImageBlock, configuration: GalleryConfiguration, fetchLivePhotoBlock: @escaping FetchLivePhotoBlock, isInitialController: Bool) {
        
        self.fetchLivePhotoBlock = fetchLivePhotoBlock
        super.init(index: index, itemCount: itemCount, fetchImageBlock: fetchImageBlock, configuration: configuration, isInitialController: isInitialController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLivePhoto()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        itemView.phLivePhotoView.startPlayback(with: .hint)
    }
    
    func fetchLivePhoto() {
        
        if let livePhotoBadge = livePhotoBadge {
            addLiveBadge(livePhotoBadge)
        }
        
        self.fetchLivePhotoBlock { livePhoto in
            self.itemView.phLivePhotoView.livePhoto = livePhoto
        }
    }
    
    func addLiveBadge(_ livePhotoBadge: UIView) {
                
        livePhotoBadge.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(livePhotoBadge)
        
        var topAnchor = self.topLayoutGuide.topAnchor
        if #available(iOS 11.0, *) {
            topAnchor = self.view.safeAreaLayoutGuide.topAnchor
        }
        let top = livePhotoBadge.topAnchor.constraint(equalTo: topAnchor, constant: 80)
        let center = livePhotoBadge.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        NSLayoutConstraint.activate([top, center])
    }
}


