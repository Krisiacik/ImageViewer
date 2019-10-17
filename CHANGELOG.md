# ImageViewer

## Version 6.0.0

* Upgrade to Swift 5 and fix subsequent compiler warnings

## Version 4.1.0

* Autoplay video ([PR #120](https://github.com/MailOnline/ImageViewer/pull/120)).
* Allow color of video controls to be set ([PR #116](https://github.com/MailOnline/ImageViewer/pull/116)).
* Support for custom "See all" close buttons ([PR #109](https://github.com/MailOnline/ImageViewer/pull/109)).
* Ability to remove an item ([PR #101](https://github.com/MailOnline/ImageViewer/pull/101)).
* Replaces `GalleryConfigurationItem.swipeToDismissHorizontally` with `.swipeToDismissMode` with options `.never`, `.vertical`, `.horizontal`, and `.always`. ([PR #99](https://github.com/MailOnline/ImageViewer/pull/99)).
* Makes `ItemBaseController` `open` ([PR #91](https://github.com/MailOnline/ImageViewer/pull/91)).
* Fixes builtin close button ([PR #90](https://github.com/MailOnline/ImageViewer/pull/90), [Issue #84](https://github.com/MailOnline/ImageViewer/issues/84)).
* Adds `GalleryItem.custom` to support subclasses of `UIImageView` ([PR #80](https://github.com/MailOnline/ImageViewer/pull/80), [Issue #56](https://github.com/MailOnline/ImageViewer/issues/56)).
* Adds activity indicator ([PR #86](https://github.com/MailOnline/ImageViewer/pull/86), [Issue #69](https://github.com/MailOnline/ImageViewer/issues/69)).
* Fixes background overlay on top of modal view controller ([PR #85](https://github.com/MailOnline/ImageViewer/pull/85), [PR #87](https://github.com/MailOnline/ImageViewer/pull/87)).
* Fixes `launchedCompletion` block execution ([PR #82](https://github.com/MailOnline/ImageViewer/pull/82)).
* Renames `GetViewControllerCompletion` to `ItemViewControllerBlock`.
* Makes `ItemBaseController` `public`.
* Adds `reload(atIndex:)` to force reload image in gallery ([PR #77](https://github.com/MailOnline/ImageViewer/pull/77), [Issue #72](https://github.com/MailOnline/ImageViewer/issues/72)).
* Fixes image appearing after async loading ([PR #76](https://github.com/MailOnline/ImageViewer/pull/76), [Issue #59](https://github.com/MailOnline/ImageViewer/issues/59)).
* Adds option to turn off decoration views toggle by single tap.
* Adds option to toggle swipe to dismiss horizontally.
* Other bugfixes and improvements

## Version 4.0

Support for Swift 3 is finally here! Enjoy! 🎉

## Version 3.1

* Swift 2.3 support.

Not published to CocoaPods yet, use tag directly:
```ruby
pod 'ImageViewer', :git => 'git@github.com:MailOnline/ImageViewer.git', :tag => '3.1'
```

## v3.0
ImageViewer 3.0 is our biggest release yet both in terms of codebase and feature evolution. We tackled the inevitable step - **video playback**. Video content is deliberately treated exactly the same way as images incl. pinch to zoom, doubleTap or swipe-to-dismiss.

We have completely redesigned the way content is displaced™ :) from the parent canvas to ImageViewer. Images and videos now seamlessly **morph** from aspectFill and other aspect-ratio-breaking modes to aspectFit FullScreen. A new built-in **Thumbnails screen** allows you to handle large sets of images and videos.

The number of **configuration options** has almost tripled. You can tweak every aspect of the complex displacement animation composition including speed & timing. Images with **transparency** are now equally supported. Main background layer allows for semitransparent color and **blur**.

* `Video support`: Show videos in the gallery. Both locally stored file and streaming is supported via video URL.
* `Thumbnails screen`: Modal screen to select any image or video immediately.
* `Composited background`: Background is now composed from two layers - the blur and the color layer. Blur intensity, color and the level of transparency for both layers is handled separately.
* `Block-based image fetching`: Now it's completely up to you to handle fetching the way you want... just pass a block that does it.
* `Rotation mode`: Option to rotate now can be set to be app based or always.
* `Spring bouncing`: Displacement can optionally include a spring bounce effect same as in the iOS Photos app.
* `Panorama support`: Very wide panorama images will still be scaled to aspectFill after double tap to zoom, even if the resize would result in a scale that exceeds maximumZoomScale.

### Config options
* `Displacement animation`: Multiple options to customize the duration and positioning of the displacement animation.
* `Background`: Customize the background colour, blur and transparency.
* `Gesture timing`: You can now set the duration in seconds for double tap to zoom gesture, decoration views hide/show animation, rotation.
* `Custom buttons`: Thumbnails and Close buttons can now be customised.
* `Maximum zoom scale`: Set the maximum zoom scale for any image or video.


## v2.0

* `Multiple Images`: Show as many images as you want in a single run.
* `Intelligent memory handling`: Thanks to behind the scenes used `UIPageViewController`'s dataSource handling, you will never experience memory warnings caused by this component. The underlying view controllers that support detail image manipulation are loaded lazily and there is never more than 4-5 of them occupying precious memory space.
* `Asynchronous background thread image loading`: In ImageViewer 1.2 you had to designate an object that conformed to our ImageProvider protocol, the viewer would then ask your object to provide an image. This protocol is now extended with a function to ask for an image at a particular index. We now guarantee that the process will not block the main thread and thus the UI.
* `Completions blocks`: To be able to hook up onto the presentation lifecycle - i.e. launch, image landing, close & swipe to dismiss states - we provide convenient completion blocks. These are exposed as optional properties and are not part of designated initializer.
* `Decoration views`: You can now set your own Close button implementation. Additionally the viewer has a concept of header and footer views. These are both opaque from the viewer's perspective, they can be any UIView subclass. Both are exposed as optional properties. They sit on top of individual images. See our built-in project example using a simple image counter as a centred header view.
* `Decoration views hiding`: Single tap the viewer's area to show/hide all decoration views.
* `Expanded configuration options`: We have expanded the list of visual related options that are now configurable.

### Config options
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

## v1.2

* `Displace image`: The image you tap will visually detach from its parent view and will become part of the full screen presentation. In our context, you can imagine an image as part of an article and when it's tapped, the image is animated into full screen.
* `Double tap to zoom`: Double tapping the image will toggle between Aspect Fit and Aspect Fill zoom scale.
* `Focused zoom`: When you double tap an image that is Aspect Fit, it will zoom in specifically focusing into the tap area.
* `Pinch to zoom`: Use the well know two finger gesture to zoom in and out.
* `Swipe to dismiss`: Close the viewer by vertically swiping and *throwing* the image away.
* `Rotation support`: ImageViewer 1.2 supports rotation regardless of rotation support in the host app.
