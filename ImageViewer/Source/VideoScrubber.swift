//
//  VideoScrubber.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 29/07/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVFoundation

public class VideoScrubber: UIControl {

    let playButton = UIButton.playButton(width: 50, height: 40)
    let pauseButton = UIButton.pauseButton(width: 50, height: 40)
    let scrubber = UISlider.createSlider(320, height: 20, pointerDiameter: 10, barHeight: 2)
    let timeLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 20)))
    var duration: NSTimeInterval?

    var player: AVObservablePlayer? {

        willSet {

            if newValue == nil {

                if let observablePlayer = player { observablePlayer.removeObserver(self, forKeyPath: AVObservablePlayer.ObservableKeyPaths.state) }
            }
        }

        didSet {
            if let _ = player { configureObservers() }
        }
    }

    override init(frame: CGRect) {

        super.init(frame: frame)

        self.clipsToBounds = true

        pauseButton.hidden = true

        scrubber.minimumValue = 0
        scrubber.maximumValue = 1000

        scrubber.value = 0

        timeLabel.attributedText = NSAttributedString(string: "--:--", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.systemFontOfSize(12)])
        timeLabel.textAlignment =  .Center

        playButton.addTarget(self, action: #selector(play), forControlEvents: UIControlEvents.TouchUpInside)
        pauseButton.addTarget(self, action: #selector(pause), forControlEvents: UIControlEvents.TouchUpInside)
        scrubber.addTarget(self, action: #selector(seekTime), forControlEvents: UIControlEvents.TouchUpInside)
        scrubber.addTarget(self, action: #selector(updateCurrentTime), forControlEvents: UIControlEvents.ValueChanged)

        self.addSubviews(playButton, pauseButton, scrubber, timeLabel)
    }

    @available (*, unavailable)
    public required init?(coder aDecoder: NSCoder) { fatalError() }

    public override func layoutSubviews() {
        super.layoutSubviews()

        playButton.center = self.boundsCenter
        playButton.frame.origin.x = 0
        pauseButton.frame = playButton.frame
        playButton.backgroundColor = UIColor.greenColor()
        pauseButton.backgroundColor = UIColor.greenColor()

        timeLabel.center = self.boundsCenter
        timeLabel.frame.origin.x = self.bounds.maxX - timeLabel.bounds.width

        scrubber.bounds.size.width = self.bounds.width - playButton.bounds.width - timeLabel.bounds.width
        scrubber.bounds.size.height = 20
        scrubber.center = self.boundsCenter
        scrubber.frame.origin.x = playButton.frame.maxX
    }

    func configureObservers() {

        self.player?.addObserver(self, forKeyPath: AVObservablePlayer.ObservableKeyPaths.state, options: NSKeyValueObservingOptions.New, context: nil)
    }

    func play() {

        self.player?.play()
    }

    func pause() {

        self.player?.pause()
    }

    func seekTime() {

        let progress = scrubber.value / scrubber.maximumValue //naturally will be between 0 to 1
        let time = self.player!.player.currentItem!.duration.toSeconds() * Double(progress)

        self.player!.seekTime(time)
    }

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if keyPath == AVObservablePlayer.ObservableKeyPaths.state {

            switch player!.state {

            case  AVObservablePlayerStateNone:

                print("NONE")
                self.playButton.hidden = true
                self.pauseButton.hidden = true
                self.updateCurrentTime()

            case  AVObservablePlayerStateReady:

                print("READY")
                self.playButton.hidden = false
                self.pauseButton.hidden = true
                updateDuration()
                updateCurrentTime()

            case  AVObservablePlayerStatePlaying:

                print("PLAYING")
                self.playButton.hidden = true
                self.pauseButton.hidden = false
                self.updateCurrentTime()

            case  AVObservablePlayerStatePaused:

                print("PAUSED")
                self.playButton.hidden = false
                self.pauseButton.hidden = true
                self.updateCurrentTime()

            case  AVObservablePlayerStateError:

                print("ERROR")
                self.playButton.hidden = true
                self.pauseButton.hidden = true


            default:
                print("UNKNOWN DAMN IT")
            }
        }

        else if keyPath == AVObservablePlayer.ObservableKeyPaths.currentTime {

            self.updateCurrentTime()
        }
    }

    func updateDuration() {

        if let duration = self.player?.player.currentItem?.duration {

            self.duration = duration.toSeconds()
        }
    }

    func updateCurrentTime() {

        if let duration = self.duration {

            let sliderProgress = scrubber.value / scrubber.maximumValue
            let currentTime = Double(sliderProgress) * duration

            let timeString = stringFromTimeInterval(currentTime as NSTimeInterval)

            timeLabel.attributedText = NSAttributedString(string: timeString, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.systemFontOfSize(12)])
        }
    }

    func stringFromTimeInterval(interval:NSTimeInterval) -> String {

        let timeInterval = NSInteger(interval)

        let seconds = timeInterval % 60
        let minutes = (timeInterval / 60) % 60
        //let hours = (timeInterval / 3600)

        return NSString(format: "%0.2d:%0.2d",minutes,seconds) as String
        //return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
    }
}
