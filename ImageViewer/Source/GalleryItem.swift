//
//  GalleryItem.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import Photos

//public typealias LivePhotoCompletion = (PHLivePhoto?) -> Void
public typealias LivePhotoCompletion = (AnyObject?) -> Void

public typealias FetchLivePhotoBlock = (@escaping LivePhotoCompletion) -> Void

public typealias ImageCompletion = (UIImage?) -> Void
public typealias FetchImageBlock = (@escaping ImageCompletion) -> Void
public typealias ItemViewControllerBlock = (_ index: Int, _ itemCount: Int, _ fetchImageBlock: FetchImageBlock, _ configuration: GalleryConfiguration, _ isInitialController: Bool) -> UIViewController

public enum GalleryItem {

    case livePhoto(fetchPreviewImageBlock: FetchImageBlock, fetchLivePhotoBlock: FetchLivePhotoBlock)
    case image(fetchImageBlock: FetchImageBlock)
    case video(fetchPreviewImageBlock: FetchImageBlock, videoURL: URL)
    case custom(fetchImageBlock: FetchImageBlock, itemViewControllerBlock: ItemViewControllerBlock)
}
