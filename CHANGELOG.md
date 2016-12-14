# ImageViewer

## Upcoming

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

## Version 4.0

* Swift 3 support.

## Version 3.1

* Swift 2.3 support.

Not published to CocoaPods yet, use tag directly:
```ruby
pod 'ImageViewer', :git => 'git@github.com:MailOnline/ImageViewer.git', :tag => '3.1'
```
