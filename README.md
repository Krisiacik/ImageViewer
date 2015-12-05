# ImageViewer

ImageViewer is a library that enables a user to visualize an image in fullscreen. Besides the typical pinch and double tap to zoom, we also provide a vertical swipe to dismiss. Finally, we try to mimic the displacement of the image from its current container into fullscreen. 

#### Usage


```swift
let buttonConfiguration = ButtonStateAssets(normalImage:UIImage(named: "normalImage"), highlightedImage:UIImage(named: "highlightedImage"))
let configuration = ImageViewerConfiguration(imageSize: size, closeButtonAssets: buttonConfiguration)

let imageProvider: ImageProvider = ... 

let imageViewer = ImageViewer(imageProvider: imageProvider, configuration: configuration, parentView: parentView)

imageViewer.show()
```

* `imageProvier`: An object that conforms to the ImageProvider protocol
* `configuration`: Contains information about the images that should be used for the close button and the size of the image about to be displayed
* `parentView`: The view that contains the `UIImageView` that is about to be displayed in fullscreen


## License
ImageViewer is licensed under the MIT License, Version 2.0. [View the license file](LICENSE)

Copyright (c) 2015 MailOnline
