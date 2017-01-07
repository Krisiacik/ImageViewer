
[![CI Status](http://img.shields.io/travis/MailOnline/ImageViewer.svg?style=flat)](https://travis-ci.org/MailOnline/ImageViewer)
[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/ImageViewer.svg?style=flat)](http://cocoadocs.org/docsets/ImageViewer)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://opensource.org/licenses/MIT)

# ImageViewer 4.0

Support for Swift 3 is finally here! Enjoy! 🎉

# ImageViewer 3.0

ImageViewer 3.0 is our biggest release yet both in terms of codebase and feature evolution. We tackled the inevitable step - **video playback**. Video content is deliberately treated exactly the same way as images incl. pinch to zoom, doubleTap or swipe-to-dismiss.

We have completely redesigned the way content is displaced™ :) from the parent canvas to ImageViewer. Images and videos now seamlessly **morph** from aspectFill and other aspect-ratio-breaking modes to aspectFit FullScreen. A new built-in **Thumbnails screen** allows you to handle large sets of images and videos.

The number of **configuration options** has almost tripled. You can tweak every aspect of the complex displacement animation composition including speed & timing. Images with **transparency** are now equally supported. Main background layer allows for semitransparent color and **blur**.

## Complete list of features

### v3.0+

* `Video support`: Show videos in the gallery. Both locally stored file and streaming is supported via video URL.
* `Thumbnails screen`: Modal screen to select any image or video immediately.
* `Composited background`: Background is now composed from two layers - the blur and the color layer. Blur intensity, color and the level of transparency for both layers is handled separately.
* `Block-based image fetching`: Now it's completely up to you to handle fetching the way you want... just pass a block that does it.
* `Rotation mode`: Option to rotate now can be set to be app based or always.
* `Spring bouncing`: Displacement can optionally include a spring bounce effect same as in the iOS Photos app.
* `Panorama support`: Very wide panorama images will still be scaled to aspectFill after double tap to zoom, even if the resize would result in a scale that exceeds maximumZoomScale.

#### Config options
* `Displacement animation`: Multiple options to customize the duration and positioning of the displacement animation.
* `Background`: Customize the background colour, blur and transparency.
* `Gesture timing`: You can now set the duration in seconds for double tap to zoom gesture, decoration views hide/show animation, rotation.
* `Custom buttons`: Thumbnails and Close buttons can now be customised.
* `Maximum zoom scale`: Set the maximum zoom scale for any image or video.


### v2.0

* `Multiple Images`: Show as many images as you want in a single run.
* `Intelligent memory handling`: Thanks to behind the scenes used `UIPageViewController`'s dataSource handling, you will never experience memory warnings caused by this component. The underlying view controllers that support detail image manipulation are loaded lazily and there is never more than 4-5 of them occupying precious memory space.
* `Asynchronous background thread image loading`: In ImageViewer 1.2 you had to designate an object that conformed to our ImageProvider protocol, the viewer would then ask your object to provide an image. This protocol is now extended with a function to ask for an image at a particular index. We now guarantee that the process will not block the main thread and thus the UI.
* `Completions blocks`: To be able to hook up onto the presentation lifecycle - i.e. launch, image landing, close & swipe to dismiss states - we provide convenient completion blocks. These are exposed as optional properties and are not part of designated initializer.
* `Decoration views`: You can now set your own Close button implementation. Additionally the viewer has a concept of header and footer views. These are both opaque from the viewer's perspective, they can be any UIView subclass. Both are exposed as optional properties. They sit on top of individual images. See our built-in project example using a simple image counter as a centred header view.
* `Decoration views hiding`: Single tap the viewer's area to show/hide all decoration views.
* `Expanded configuration options`: We have expanded the list of visual related options that are now configurable.

#### Config options
* `Paging Mode`: Set the viewer to either go from first to last image or work in a carousel mode in an infinite loop.
* `Decoration view pinning`: You can choose what kind of layout behaviour serves your needs best. Close button, header & footer views can all be pinned to left or right or kept in the centre.
* `Spine width`: Set the width of the spine that separates images from each other.
* `Hide status bar`: You can hide the status bar while the gallery is visible.
* `Hide decoration views initially`: You can set the decoration views to be hidden on start.
* `Spinner customization`: We are showing an activity indicator while the image is loading. You can set its style and color.
* `Horizontal swipe to dismiss`: If you run the viewer in Standard (non-carousel) mode, once you reach the beginning or the end of image collection, the next horizontal swipe will dismiss the whole viewer. This gesture is interactive and cancelable.
* `Image displacement`: Displacement still works, we now also keep track of the displaced image index, that means if you page back and forth through images, and you page to the originally displaced image, tapping the close button will return the image to its position in the parent view. Closing with any other image uses the standard cross-dissolve transition.
* `Host app rotation support`: Previously, we handled rotations separately from the host app. We kept this, meaning you can still get rotations for a portrait only app, but now we also support being hosted in an app that has rotations enabled globally.
* `Butter smooth & super fast rotation re-layout with correct anchor points`: All the views in a view hierarchy follow the most logical paths when resizing (because of rotation), images rotate around their natural centers all thanks to the magic of manual layout. (Sorry auto-layout engine, you are a bit slow on a 4S)
* `Transition to current rotated state`: Tapping any image in your parent view will launch the viewer in a rotated state and displace the image while rotating it to its desired position at the same time. We couldn't resist :)

### v1.2

* `Displace image`: The image you tap will visually detach from its parent view and will become part of the full screen presentation. In our context, you can imagine an image as part of an article and when it's tapped, the image is animated into full screen.
* `Double tap to zoom`: Double tapping the image will toggle between Aspect Fit and Aspect Fill zoom scale.
* `Focused zoom`: When you double tap an image that is Aspect Fit, it will zoom in specifically focusing into the tap area.
* `Pinch to zoom`: Use the well know two finger gesture to zoom in and out.
* `Swipe to dismiss`: Close the viewer by vertically swiping and *throwing* the image away.
* `Rotation support`: ImageViewer 1.2 supports rotation regardless of rotation support in the host app.

## Setup

### ImageViewer version vs Swift version.

ImageViewer 4.0 is Swift 3 ready! 🎉

If you use earlier version of Swift - refer to a table below:

| Swift version | ImageViewer version               |
| ------------- | --------------------------------- |
| 3.X           | >= 4.0                            |
| 2.3           | 3.1 [⚠️](CHANGELOG.md#version-31) |
| 2.2           | <= 2.1                            |

### CocoaPods

```ruby
# source 'https://github.com/CocoaPods/Specs.git'
# use_frameworks!
# platform :ios, "8.0"

pod 'ImageViewer'
```

### Carthage

```ruby
github "MailOnline/ImageViewer"
```

## Sample Usage

```swift
let galleryViewController = GalleryViewController(startIndex: displacedViewIndex, itemsDataSource: self, displacedViewsDataSource: self, configuration: galleryConfiguration)
self.presentImageGallery(galleryViewController)
```

## License

ImageViewer is licensed under the MIT License, Version 2.0. See the [LICENSE](LICENSE) file for more info.

Copyright (c) 2016 MailOnline
