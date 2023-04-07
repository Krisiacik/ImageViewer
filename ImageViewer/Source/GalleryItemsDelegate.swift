//
//  GalleryDelegate.swift
//  ImageViewer
//
// Created by David Whetstone on 1/5/17.
// Copyright (c) 2017 MailOnline. All rights reserved.
//

import Foundation

public protocol GalleryItemsDelegate: class {

    func removeGalleryItem(at index: Int)
    func shouldRemoveGalleryItem(at index: Int, block: @escaping (Bool) -> Void)
}

extension GalleryItemsDelegate {
    func shouldRemoveGalleryItem(at index: Int, block: @escaping (Bool) -> Void) {
        block(true)
    }
}
