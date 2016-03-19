//
//  ViewController.swift
//  footMan
//
//  Created by futeshi on 2016/03/19.
//  Copyright © 2016年 ftsan. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    // 時間更新のタイミング
    var timeDisplayInterval: NSTimeInterval = 0.01
    var secondsToEndTimer: NSTimeInterval = 0.0
    var timeIntervalCouunter: NSTimeInterval = 0.0
    let pedometer = CMPedometer()
    var timer = NSTimer()
    var checkIfTiming = false
    var isCounting = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func requestAuthorization() {
        // CMPedometerが利用できるか確認
        if CMPedometer.isStepCountingAvailable() {
            print("StepCountingAvailable")
            // 計測開始
            pedometer.startPedometerUpdatesFromDate(NSDate(), withHandler: {
                [unowned self] data, error in
                dispatch_async(dispatch_get_main_queue(), {
                    print("update")
                    if error != nil {
                        // エラー
                        self.timeLabel.text = "エラー : \(error)"
                        print("エラー : \(error)")
                    } else {
                        let lengthFormatter = NSLengthFormatter()
                        print("success")
                        let d = data!
                        // 歩数
                        
                        self.stepLabel.text = String(d.numberOfSteps)
                        // 距離
                        self.distanceLabel.text = lengthFormatter.stringFromMeters( d.distance!.doubleValue)
                    }
                })
            })
        } else {
            print("Authrization error")
        }
    }

    @IBAction func startPauseButtonPressed(sender: UIButton) {
        if isCounting {
            let start = UIImage(named: "start") as UIImage!
            startPauseButton.setImage(start, forState: .Normal)
            startPauseButton.layer.shadowOpacity = 0.0
            isCounting = false
        } else {
            requestAuthorization()
            startPauseButton.layer.shadowOpacity = 0.9
            startPauseButton.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
            startPauseButton.layer.shadowRadius = 5.0
            startPauseButton.layer.shadowColor = UIColor.blackColor().CGColor
            
            timer.invalidate()
            checkIfTiming = false
            startPauseButton.setImage(UIImage(named:
                "pauseButton"), forState: .Normal)
            isCounting = true
            startPauseButton.layer.shadowOpacity = 0.0
        }
        
        if !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(timeDisplayInterval, target: self, selector: "countUp:", userInfo: nil, repeats: true)
            checkIfTiming = true
        } else {
            timer.invalidate()
        }
        timeLabel.text = formattedTimeString(timeIntervalCouunter)
    }
    
    @IBAction func resetButtonPressed(sender: AnyObject) {
        timer.invalidate()
        
        timeIntervalCouunter = secondsToEndTimer
        timeLabel.text = formattedTimeString(timeIntervalCouunter)

        stepLabel.text = String(0)
        distanceLabel.text = String(0.00)
        checkIfTiming = false
        
        startPauseButton.setImage(UIImage(named: "start"), forState: .Normal)
        
        startPauseButton.layer.shadowOpacity = 0.0

        self.stepLabel.text = String(0)
        // 距離
        self.distanceLabel.text = String(0.00)

        isCounting = false
        
        resetButton.layer.shadowOpacity = 1.0
        resetButton.layer.shadowOffset = CGSize(width: 1.0, height: 0.5)
        resetButton.layer.shadowRadius = 2.0
        resetButton.layer.shadowColor = UIColor.blackColor().CGColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func formattedTimeString(time: NSTimeInterval) -> String {
        let min = Int(time) / 60
        let secs = Int(time) % 60
        // return String(format: "%02i:%02i", min, secs)
        
        let fracs = Int((time - Double(min * 60) - Double(secs)) * 100.0)
        return String(format: "%02i:%02i:%02i", min, secs, fracs)
    }

    func countUp(time: NSTimer) {
        timeIntervalCouunter += timeDisplayInterval
        timeLabel.text = formattedTimeString(timeIntervalCouunter)
    }

}
