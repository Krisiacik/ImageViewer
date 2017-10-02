
[![CI Status](http://img.shields.io/travis/MailOnline/ImageViewer.svg?style=flat)](https://travis-ci.org/MailOnline/ImageViewer)
[![Swift 3.1](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/ImageViewer.svg?style=flat)](http://cocoadocs.org/docsets/ImageViewer)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://opensource.org/licenses/MIT)

![Single image view](https://github.com/MailOnline/ImageViewer/blob/master/Documentation/single.gif)

![Gallery](https://github.com/MailOnline/ImageViewer/blob/master/Documentation/gallery.gif)

For the latest changes see the [CHANGELOG](CHANGELOG.md)

## Install

### CocoaPods

```ruby
pod 'ImageViewer'
```

### Carthage

```ruby
github "MailOnline/ImageViewer"
```

## Sample Usage

For a detailed example, see the [Example](https://github.com/MailOnline/ImageViewer/tree/master/Example)!

```swift
// Show the ImageViewer with with the first item
self.presentImageGallery(GalleryViewController(startIndex: 0, itemsDataSource: self))

// The GalleryItemsDataSource provides the items to show
extension ViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return items.count
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return items[index].galleryItem
    }
}

```

### ImageViewer version vs Swift version.

ImageViewer 5.0+ is Swift 4 ready! 🎉

If you use earlier version of Swift - refer to the table below:

| Swift version | ImageViewer version               |
| ------------- | --------------------------------- |
| 4.x           | >= 5.0                            |
| 3.x           | 4.0                               |
| 2.3           | 3.1 [⚠️](CHANGELOG.md#version-31) |
| 2.2           | <= 2.1                            |

## License

ImageViewer is licensed under the MIT License, Version 2.0. See the [LICENSE](LICENSE) file for more info.

Copyright (c) 2016 MailOnline
