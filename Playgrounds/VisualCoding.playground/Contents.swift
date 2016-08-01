
import UIKit
import ImageViewer
import XCPlayground
import AVFoundation

func aspectFitSize(forContentOfSize contentSize: CGSize, inBounds bounds: CGSize) -> CGSize {

    return AVMakeRectWithAspectRatioInsideRect(contentSize, CGRect(origin: CGPointZero, size: bounds)).size
}

let rootView = UIView(frame: CGRect(x: 0, y: 100, width: 320, height: 568))
rootView.backgroundColor = UIColor.blackColor()
let imageView = UIImageView(image: UIImage(named: "predator"))
imageView.bounds.size = aspectFitSize(forContentOfSize: imageView.bounds.size, inBounds: rootView.bounds.size)
imageView.frame.origin = CGPoint(x: 0, y: 170)
rootView.addSubview(imageView)

let scrubber = VideoScrubber()
scrubber.frame = CGRect(x: 0, y: 385, width: 320, height: 40)

rootView.addSubview(scrubber)


XCPlaygroundPage.currentPage.liveView = rootView


