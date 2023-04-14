//
//  GalleryItem.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 01/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVKit

public typealias ImageCompletion = (UIImage?) -> Void
public typealias VideoCompletion = (AVAsset?) -> Void
public typealias FetchImageBlock = (@escaping ImageCompletion) -> Void
public typealias FetchVideoBlock = (@escaping VideoCompletion) -> Void
public typealias ItemViewControllerBlock = (_ index: Int, _ itemCount: Int, _ fetchImageBlock: FetchImageBlock, _ configuration: GalleryConfiguration, _ isInitialController: Bool) -> UIViewController

public enum GalleryItem {

    case image(fetchImageBlock: FetchImageBlock)
    case video(fetchPreviewImageBlock: FetchImageBlock, videoURL: URL)
    case rawVideo(fetchPreviewImageBlock: FetchImageBlock, fetchRawVideoBlock: FetchVideoBlock)
    case custom(fetchImageBlock: FetchImageBlock, itemViewControllerBlock: ItemViewControllerBlock)
}
