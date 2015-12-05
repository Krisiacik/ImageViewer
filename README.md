# ImageViewer

ImageViewer is a library that enables a user to visualize an image in fullscreen. Besides the typical pinch and double tap to zoom, we also provide a vertical swipe to dismiss.

#### Usage


```swift
let buttonConfiguration = ButtonStateAssets(normalImage:UIImage(named: "normalImage"), highlightedImage:UIImage(named: "highlightedImage"))
let configuration = ImageViewerConfiguration(imageSize: articleImage.size, closeButtonAssets: buttonConfiguration)

// An object that conforms to the ImageProvider protocol
let imageProvider: ImageProvider = ... 

let imageViewer = ImageViewer(imageProvider: imageProvider, configuration: configuration, parentView: parentView)

imageViewer.show()
```


## License
ImageViewer is licensed under the MIT License, Version 2.0. [View the license file](LICENSE)

Copyright (c) 2015 MailOnline
