//
//  GalleryConfiguration.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 04/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public typealias GalleryConfiguration = [GalleryConfigurationItem]

public enum GalleryConfigurationItem {

    /// Allows to stop paging at the beginning and the end of item list or page infinitely in a "carousel" like mode.
    case pagingMode(GalleryPagingMode)

    /// Distance (width of the area) between images when paged.
    case imageDividerWidth(CGFloat)

    ///Option to set the Close button type.
    case closeButtonMode(ButtonMode)
    
    ///Option to set the Close button type  within the Thumbnails screen.
    case seeAllCloseButtonMode(ButtonMode)

    ///Option to set the Thumbnails button type.
    case thumbnailsButtonMode(ButtonMode)

    ///Option to set the Delete button type.
    case deleteButtonMode(ButtonMode)

    /// Layout behaviour for the Close button.
    case closeLayout(ButtonLayout)

    /// Layout behaviour for the Close button within the Thumbnails screen.
    case seeAllCloseLayout(ButtonLayout)
    
    /// Layout behaviour for the Thumbnails button.
    case thumbnailsLayout(ButtonLayout)

    /// Layout behaviour for the Delete button.
    case deleteLayout(ButtonLayout)

    /// This spinner is shown when we page to an image page, but the image itself is still loading.
    case spinnerStyle(UIActivityIndicatorViewStyle)

    /// Tint color for the spinner.
    case spinnerColor(UIColor)

    /// Layout behaviour for optional header view.
    case headerViewLayout(HeaderLayout)

    /// Layout behaviour for optional footer view.
    case footerViewLayout(FooterLayout)

    /// Sets the status bar visible/invisible while gallery is presented.
    case statusBarHidden(Bool)

    /// Sets the close button, header view and footer view visible/invisible on launch. Visibility of these three views is toggled by single tapping anywhere in the gallery area. This setting is global to Gallery.
    case hideDecorationViewsOnLaunch(Bool)

    ///Allows to turn on/off decoration views hiding via single tap.
    case toggleDecorationViewsBySingleTap(Bool)

    ///Allows to uiactivityviewcontroller with itemview via long press.
    case activityViewByLongPress(Bool)

    /// Allows you to select between different types of initial gallery presentation style
    case presentationStyle(GalleryPresentationStyle)

    ///Allows to set maximum magnification factor for the image
    case maximumZoomScale(CGFloat)

    ///Sets the duration of the animation when item is double tapped and transitions between ScaleToAspectFit & ScaleToAspectFill sizes.
    case doubleTapToZoomDuration(TimeInterval)

    ///Transition duration for the blur layer component of the overlay when Gallery is being presented.
    case blurPresentDuration(TimeInterval)

    ///Delayed start for the transition of the blur layer component of the overlay when Gallery is being presented.
    case blurPresentDelay(TimeInterval)

    ///Transition duration for the color layer component of the overlay when Gallery is being presented.
    case colorPresentDuration(TimeInterval)

    ///Delayed start for the transition of color layer component of the overlay when Gallery is being presented.
    case colorPresentDelay(TimeInterval)

    ///Delayed start for decoration views transition (fade-in) when Gallery is being presented.
    case decorationViewsPresentDelay(TimeInterval)

    ///Transition duration for the blur layer component of the overlay when Gallery is being dismissed.
    case blurDismissDuration(TimeInterval)

    ///Transition delay for the blur layer component of the overlay when Gallery is being dismissed.
    case blurDismissDelay(TimeInterval)

    ///Transition duration for the color layer component of the overlay when Gallery is being dismissed.
    case colorDismissDuration(TimeInterval)

    ///Transition delay for the color layer component of the overlay when Gallery is being dismissed.
    case colorDismissDelay(TimeInterval)

    ///Transition duration for the item when the fade-in/fade-out effect is used globally for items while Gallery is being presented /dismissed.
    case itemFadeDuration(TimeInterval)

    ///Transition duration for decoration views when they fade-in/fade-out after single tap.
    case decorationViewsFadeDuration(TimeInterval)

    ///Duration of animated re-layout after device rotation.
    case rotationDuration(TimeInterval)

    /// Duration of the displacement effect when gallery is being presented.
    case displacementDuration(TimeInterval)

    /// Duration of the displacement effect when gallery is being dismissed.
    case reverseDisplacementDuration(TimeInterval)

    ///Setting this to true is useful when your overlay layer is not fully opaque and you have multiple images on screen at once. The problem is image 1 is going to be displaced (gallery is being presented) and you can see that it is missing in the parent canvas because it "left the canvas" and the canvas bleeds its content through the overlay layer. However when you page to a different image and you decide to dismiss the gallery, that different image is going to be returned (using reverse displacement). That looks a bit strange because it is reverse displacing but it actually is already present in the parent canvas whereas the original image 1 is still missing there. There is no meaningful way to manage these displaced views. This setting helps to avoid it his problem by keeping the originals in place while still using the displacement effect.
    case displacementKeepOriginalInPlace(Bool)

    ///Provides the most typical timing curves for the displacement transition.
    case displacementTimingCurve(UIViewAnimationCurve)

    ///Allows to optionally set a spring bounce when the displacement transition finishes.
    case displacementTransitionStyle(GalleryDisplacementStyle)

    ///For the image to be reverse displaced, it must be visible in the parent view frame on screen, otherwise it's pointless to do the reverse displacement animation as we would be animating to out of bounds of the screen. However, there might be edge cases where only a tiny percentage of image is visible on screen, so reverse-displacing to that might not be desirable / visually pleasing. To address this problem, we can define a valid area that will be smaller by a given margin and sit centered inside the parent frame. For example, setting a value of 20 means the reverse displaced image must be in a rect that is inside the parent frame and the margin on all sides is to the parent frame is 20 points.
    case displacementInsetMargin(CGFloat)

    ///Base color of the overlay layer that is mostly visible when images are displaced (gallery is being presented), rotated and interactively dismissed.
    case overlayColor(UIColor)

    ///Allows to select the overall tone on the B&W scale of the blur layer in the overlay.
    case overlayBlurStyle(UIBlurEffectStyle)

    ///The opacity of overlay layer when the displacement effect finishes anf the gallery is fully presented. Valid values are from 0 to 1 where 1 is full opacity i.e the overlay layer is fully opaque, 0 is completely transparent and effectively invisible.
    case overlayBlurOpacity(CGFloat)

    ///The opacity of overlay layer when the displacement effect finishes anf the gallery is fully presented. Valid values are from 0 to 1 where 1 is full opacity i.e the overlay layer is fully opaque, 0 is completely transparent and effectively invisible.
    case overlayColorOpacity(CGFloat)

    ///The minimum velocity needed for the image to continue on its swipe-to-dismiss path instead of returning to its original position. The velocity is in scalar units per second, which in our case represents points on screen per second. When the thumb moves on screen and eventually is lifted, it traveled along a path and the speed represents the number of points it traveled in the last 1000 msec before it was lifted.
    case swipeToDismissThresholdVelocity(CGFloat)

    ///Allows to decide direction of swipe to dismiss, or disable it altogether
    case swipeToDismissMode(GallerySwipeToDismissMode)

    ///Allows to set rotation support support with relation to rotation support in the hosting app.
    case rotationMode(GalleryRotationMode)
    
    ///Allows the video player to automatically continue playing the next video
    case continuePlayVideoOnEnd(Bool)

    ///Allows auto play video after gallery presented
    case videoAutoPlay(Bool)

    ///Tint color of video controls
    case videoControlsColor(UIColor)
}

public enum GalleryRotationMode {

    ///Gallery will rotate to orientations supported in the application.
    case applicationBased

    ///Gallery will rotate regardless of the rotation setting in the application.
    case always
}

public enum ButtonMode {

    case none
    case builtIn /// Standard Close or Thumbnails button.
    case custom(UIButton)
}

public enum GalleryPagingMode {

    case standard /// Allows paging through images from 0 to N, when first or last image reached ,horizontal swipe to dismiss kicks in.
    case carousel /// Pages through images from 0 to N and the again 0 to N in a loop, works both directions.
}

public enum GalleryDisplacementStyle {

    case normal
    case springBounce(CGFloat) ///
}

public enum GalleryPresentationStyle {

    case fade
    case displacement
}

public struct GallerySwipeToDismissMode: OptionSet {

    public init(rawValue: Int) { self.rawValue = rawValue }
    public let rawValue: Int

    public static let never      = GallerySwipeToDismissMode(rawValue: 0)
    public static let horizontal = GallerySwipeToDismissMode(rawValue: 1 << 0)
    public static let vertical   = GallerySwipeToDismissMode(rawValue: 1 << 1)
    public static let always: GallerySwipeToDismissMode = [ .horizontal, .vertical ]
}
