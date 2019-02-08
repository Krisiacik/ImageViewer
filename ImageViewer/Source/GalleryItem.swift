//
//  GalleryItem.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import Photos

@available(iOS 9.1, *)
public typealias LivePhotoCompletion = (PHLivePhoto?) -> Void

@available(iOS 9.1, *)
public typealias FetchLivePhotoBlock = (@escaping LivePhotoCompletion) -> Void

public typealias ImageCompletion = (UIImage?) -> Void
public typealias FetchImageBlock = (@escaping ImageCompletion) -> Void
public typealias ItemViewControllerBlock = (_ index: Int, _ itemCount: Int, _ fetchImageBlock: FetchImageBlock, _ configuration: GalleryConfiguration, _ isInitialController: Bool) -> UIViewController

public enum GalleryItem {

    @available(iOS 9.1, *)
    case livePhoto(fetchPreviewImageBlock: FetchImageBlock, fetchLivePhotoBlock: FetchLivePhotoBlock)
    
    case image(fetchImageBlock: FetchImageBlock)
    case video(fetchPreviewImageBlock: FetchImageBlock, videoURL: URL)
    case custom(fetchImageBlock: FetchImageBlock, itemViewControllerBlock: ItemViewControllerBlock)
}
