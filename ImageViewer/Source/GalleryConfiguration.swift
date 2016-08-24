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
    case PagingMode(GalleryPagingMode)
    
    /// Distance (width of the area) between images when paged.
    case ImageDividerWidth(CGFloat)
    
    ///Option to set the Close button type.
    case CloseButtonMode(GalleryCloseButtonMode)
    
    /// Layout behaviour for the close button.
    case CloseLayout(CloseButtonLayout)

    /// This spinner is shown when we page to an image page, but the image itself is still loading.
    case SpinnerStyle(UIActivityIndicatorViewStyle)

    /// Tint color for the spinner.
    case SpinnerColor(UIColor)
    
    /// Layout behaviour for optional header view.
    case HeaderViewLayout(HeaderLayout)
    
    /// Layout behaviour for optional footer view.
    case FooterViewLayout(FooterLayout)
    
    /// Sets the status bar visible/invisible while gallery is presented.
    case StatusBarHidden(Bool)
    
    /// Sets the close button, header view and footer view visible/invisible on launch. Visibility of these three views is toggled by single tapping anywhere in the gallery area. This setting is global to Gallery.
    case HideDecorationViewsOnLaunch(Bool)

    /// Allows you to select between different types of initial gallery presentation style
    case PresentationStyle(GalleryPresentationStyle)

    ///Allows to set maximum magnification factor for the image
    case MaximumZoolScale(CGFloat)
    
    ///Sets the duration of the animation when item is double tapped and transitions between ScaleToAspectFit & ScaleToAspectFill sizes.
    case DoubleTapToZoomDuration(NSTimeInterval)

    ///Transition duration for the blur layer component of the overlay when Gallery is being presented.
    case BlurPresentDuration(NSTimeInterval)
    
    ///Delayed start for the transition of the blur layer component of the overlay when Gallery is being presented.
    case BlurPresentDelay(NSTimeInterval)

    ///Transition duration for the color layer component of the overlay when Gallery is being presented.
    case ColorPresentDuration(NSTimeInterval)

    ///Delayed start for the transition of color layer component of the overlay when Gallery is being presented.
    case ColorPresentDelay(NSTimeInterval)

    ///Delayed start for decoration views transition (fade-in) when Gallery is being presented.
    case DecorationViewsPresentDelay(NSTimeInterval)

    ///Transition duration for the blur layer component of the overlay when Gallery is being dismissed.
    case BlurDismissDuration(NSTimeInterval)

    ///Transition delay for the blur layer component of the overlay when Gallery is being dismissed.
    case BlurDismissDelay(NSTimeInterval)

    ///Transition duration for the color layer component of the overlay when Gallery is being dismissed.
    case ColorDismissDuration(NSTimeInterval)

    ///Transition delay for the color layer component of the overlay when Gallery is being dismissed.
    case ColorDismissDelay(NSTimeInterval)

    ///Transition duration for the item when the fade-in/fade-out effect is used globaly for items while Gallery is being presented /dismissed.
    case ItemFadeDuration(NSTimeInterval)
    
    ///Transition duration for decoration views when they fade-in/fade-out after single tap.
    case DecorationViewsFadeDuration(NSTimeInterval)

    ///Duration of animated re-layout after device rotation.
    case RotationDuration(NSTimeInterval)
    
    /// Duration of the displacement effect when gallery is being presented.
    case DisplacementDuration(NSTimeInterval)

    /// Duration of the displacement effect when gallery is being dismissed.
    case ReverseDisplacementDuration(NSTimeInterval)

    ///Setting this to true is useful when your overlay layer is not fully opaque and you have multiple images on screen at once. The problem is image 1 is going to be displaced (gallery is being presented) and you can see that it is missing in the parent canvas because it "left the canvas" and the canvas bleeds its content through the overlay layer. However when you page to a different image and you decide to dismiss the gallery, that different image is going to be returned (using reveserse displacement). Thats look a bit strange because it is reverse displacing but it actually is already present in the parent canvas whereas the original image 1 is still missing there. Thre is no meaningful way to manage these deisplaced views. This setting helps to avoid it his problem by keeping the originals in place while still using the displacement effect.
    case DisplacementKeepOriginalInPlace(Bool)
    
    ///Provides the most typical timing curves for the displacement transition.
    case DisplacementTimingCurve(UIViewAnimationCurve)
    
    ///Alows to optionaly set a spring bounce when the displacement transition finishes.
    case DisplacementTransitionStyle(GalleryDisplacementStyle)
    
    ///Base color of the overlay layer that is mostly visible when images are displaced (gallery is being presented), rotated and interactively dismissed.
    case OverlayColor(UIColor)
    
    ///Allows to select the overall tone on the B&W scale of the blur layer in the overlay.
    case OverlayBlurStyle(UIBlurEffectStyle)
    
    ///The opacity of overlay layer when the displacement effect finishes anf the gallery is fully presented. Valid values are from 0 to 1 where 1 is full opacity i.e the overlay layer is fully opaque, 0 is completely transparent and effectively invisible.
    case OverlayBlurOpacity(CGFloat)
    
    ///The opacity of overlay layer when the displacement effect finishes anf the gallery is fully presented. Valid values are from 0 to 1 where 1 is full opacity i.e the overlay layer is fully opaque, 0 is completely transparent and effectively invisible.
    case OverlayColorOpacity(CGFloat)
    
    ///The minimum velocity needed for the image to continue on its swipe-to-dismiss path instead of returning to its original position. The velocity is in scalar units per second, which in our case represents points on screen per second. When the thumb moves on screen and eventually is lifted, it traveled along a path and the speed represents the number of points it traveled in the last 1000 msec before it was lifted.
    case SwipeToDismissThresholdVelocity(CGFloat)

    ///Allows to set rotation support support with relation to rotation support in the hosting app.
    case RotationMode(GalleryRotationMode)
}

public enum GalleryRotationMode {

    ///Gallery will rotate to orientations supported in the application.
    case ApplicationBased

    ///Galleyr will rotate regardless of the rotation setting in the application.
    case Always
}

public enum GalleryCloseButtonMode {
    
    case None
    case BuiltIn /// Standard white X with transparent tappable area, positioned in the top right corner.
    case Custom(UIButton)
}

public enum GalleryPagingMode {
    
    case Standard /// Allows paging through images from 0 to N, when first or last image reached ,horizontal swipe to dismiss kicks in.
    case Carousel /// Pages through images from 0 to N and the again 0 to N in a loop, works both directions.
}

public enum GalleryDisplacementStyle {
    
    case Normal
    case SpringBounce(CGFloat) ///
}

public enum GalleryPresentationStyle {
    
    case Fade
    case Displacement
}
