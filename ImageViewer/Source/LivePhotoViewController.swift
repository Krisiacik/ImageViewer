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
    
    var livePhotoBadgeTopConstraint: NSLayoutConstraint?
    var livePhotoBadge: UIView?
    
    init(index: Int, itemCount: Int, fetchImageBlock: @escaping FetchImageBlock, configuration: GalleryConfiguration, fetchLivePhotoBlock: @escaping FetchLivePhotoBlock, isInitialController: Bool) {
        
        self.fetchLivePhotoBlock = fetchLivePhotoBlock
        super.init(index: index, itemCount: itemCount, fetchImageBlock: fetchImageBlock, configuration: configuration, isInitialController: isInitialController)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLivePhoto()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        itemView.phLivePhotoView.startPlayback(with: .hint)
    }
    
    
    override func closeDecorationViews(_ duration: TimeInterval) {
        
        UIView.animate(withDuration: duration, animations: { [weak self] in
            
            self?.livePhotoBadge?.alpha = 0
        })
    }
    
    func fetchLivePhoto() {
        
        if let livePhotoBadge = livePhotoBadgeCreator?() {
            
            self.livePhotoBadge = livePhotoBadge
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
        livePhotoBadgeTopConstraint = livePhotoBadge.topAnchor.constraint(equalTo: topAnchor, constant: 80)
        let center = livePhotoBadge.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        NSLayoutConstraint.activate([livePhotoBadgeTopConstraint!, center])
    }
    
    @objc func deviceOrientationDidChange() {
        
        livePhotoBadgeTopConstraint?.constant = UIDevice.current.orientation.isLandscape ? 16 : 80
    }
    
}


