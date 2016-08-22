//
//  VideoScrubber.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 08/08/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit
import AVFoundation

public class VideoScrubber: UIControl {

    let playButton = UIButton.playButton(width: 50, height: 40)
    let pauseButton = UIButton.pauseButton(width: 50, height: 40)
    let replayButton = UIButton.replayButton(width: 50, height: 40)

    let scrubber = Slider.createSlider(320, height: 20, pointerDiameter: 10, barHeight: 2)
    let timeLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 20)))
    var duration: NSTimeInterval?
    private var periodicObserver: AnyObject?
    private var stoppedSlidingTimeStamp = NSDate()

    weak var player: AVPlayer? {

        willSet {

            if newValue == nil {

                if let player = player {

                    ///KVO
                    player.removeObserver(self, forKeyPath: "status")
                    player.removeObserver(self, forKeyPath: "rate")
                    scrubber.removeObserver(self, forKeyPath: "isSliding")

                    ///NC
                    NSNotificationCenter.defaultCenter().removeObserver(self)

                    ///TIMER
                    if let periodicObserver = self.periodicObserver {

                        player.removeTimeObserver(periodicObserver)
                        self.periodicObserver = nil
                    }
                }
            }
        }

        didSet {

            print(player)

            if let player = player {

                ///KVO
                player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil)
                player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.New, context: nil)
                scrubber.addObserver(self, forKeyPath: "isSliding", options: NSKeyValueObservingOptions.New, context: nil)

                ///NC
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didEndPlaying), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)

                ///TIMER
                periodicObserver = player.addPeriodicTimeObserverForInterval(CMTime(value: 1, timescale: 1), queue: nil) { [weak self] time in

                    if let weakself = self {
                        weakself.update()
                    }
                }

                self.update()
            }
        }
    }

    override init(frame: CGRect) {

        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        setup()
    }

    deinit {

        player?.removeObserver(self, forKeyPath: "status")
        player?.removeObserver(self, forKeyPath: "rate")
        scrubber.removeObserver(self, forKeyPath: "isSliding")

        if let periodicObserver = self.periodicObserver {

            player?.removeTimeObserver(periodicObserver)
            self.periodicObserver = nil
        }
    }

    func didEndPlaying() {

        self.playButton.hidden = true
        self.pauseButton.hidden = true
        self.replayButton.hidden = false
    }

    func setup() {

//        self.backgroundColor = UIColor.greenColor()
//        self.playButton.backgroundColor = UIColor.redColor()
//        self.pauseButton.backgroundColor = UIColor.redColor()

        self.clipsToBounds = true
        pauseButton.hidden = true
        replayButton.hidden = true

        scrubber.minimumValue = 0
        scrubber.maximumValue = 1000
        scrubber.value = 0

        timeLabel.attributedText = NSAttributedString(string: "--:--", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.systemFontOfSize(12)])
        timeLabel.textAlignment =  .Center

        playButton.addTarget(self, action: #selector(play), forControlEvents: UIControlEvents.TouchUpInside)
        pauseButton.addTarget(self, action: #selector(pause), forControlEvents: UIControlEvents.TouchUpInside)
        replayButton.addTarget(self, action: #selector(replay), forControlEvents: UIControlEvents.TouchUpInside)
        scrubber.addTarget(self, action: #selector(updateCurrentTime), forControlEvents: UIControlEvents.ValueChanged)
        scrubber.addTarget(self, action: #selector(seekToTime), forControlEvents: [UIControlEvents.TouchUpInside, UIControlEvents.TouchUpOutside])

        self.addSubviews(playButton, pauseButton, replayButton, scrubber, timeLabel)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        playButton.center = self.boundsCenter
        playButton.frame.origin.x = 0
        pauseButton.frame = playButton.frame
        replayButton.frame = playButton.frame

        timeLabel.center = self.boundsCenter
        timeLabel.frame.origin.x = self.bounds.maxX - timeLabel.bounds.width

        scrubber.bounds.size.width = self.bounds.width - playButton.bounds.width - timeLabel.bounds.width
        scrubber.bounds.size.height = 20
        scrubber.center = self.boundsCenter
        scrubber.frame.origin.x = playButton.frame.maxX
    }

    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if keyPath == "isSliding" {

            if scrubber.isSliding == false {

                stoppedSlidingTimeStamp = NSDate()
            }
        }

        else if keyPath == "rate" || keyPath == "status" {

            self.update()
        }
    }

    func play() {

        self.player?.play()
    }

    func replay() {

        self.player?.seekToTime(CMTime(value:0 , timescale: 1))
        self.player?.play()
    }

    func pause() {

        self.player?.pause()
    }

    func seekToTime() {

        let progress = scrubber.value / scrubber.maximumValue //naturally will be between 0 to 1

        if let player = self.player, let currentItem =  player.currentItem {

            let time = currentItem.duration.seconds * Double(progress)
            player.seekToTime(CMTime(seconds: time, preferredTimescale: 1))
        }
    }

    func update() {

        updateButtons()
        updateDuration()
        updateScrubber()
        updateCurrentTime()
    }

    func updateButtons() {

        if let player = self.player {

            self.playButton.hidden = player.isPlaying()
            self.pauseButton.hidden = !self.playButton.hidden
            self.replayButton.hidden = true
        }
    }

    func updateDuration() {

        if let duration = self.player?.currentItem?.duration {

            self.duration = (duration.isNumeric) ? duration.seconds : nil
        }
    }

    func updateScrubber() {

        guard scrubber.isSliding == false else { return }

        let timeElapsed = NSDate().timeIntervalSinceDate( stoppedSlidingTimeStamp)
        guard timeElapsed > 1 else {
            return
        }

        if let player = self.player, duration = self.duration {

            let progress = player.currentTime().seconds / duration

            UIView.animateWithDuration(0.9) { [weak self] in

                if let weakself = self {

                    weakself.scrubber.value = Float(progress) * weakself.scrubber.maximumValue
                }
            }
        }
    }

    func updateCurrentTime() {

        if let duration = self.duration where self.duration != nil {

            let sliderProgress = scrubber.value / scrubber.maximumValue
            let currentTime = Double(sliderProgress) * duration

            let timeString = stringFromTimeInterval(currentTime as NSTimeInterval)

            timeLabel.attributedText = NSAttributedString(string: timeString, attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.systemFontOfSize(12)])
        }
        else {
            timeLabel.attributedText = NSAttributedString(string: "--:--", attributes: [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName : UIFont.systemFontOfSize(12)])
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
