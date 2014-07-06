//
//  TMViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 6/30/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol Ticker {
    func Tick(timeLeft:Double)
    func Timeout()
}

class CountdownTimerModel :NSObject {
    var timeLeft:Double
    var timer:NSTimer?
    var delegate:AnyObject

    init(initialTime:Double, delegate:AnyObject) {
        timeLeft = initialTime
        self.delegate = delegate
    }

    func startCountdown() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tick", userInfo: nil, repeats: true)
    }

    func tick() {
        timeLeft -= 1
        self.delegate.Tick(timeLeft)
        if (timeLeft == 0) {
            self.timer?.invalidate()
            self.delegate.Timeout()
        }
    }
}

class TMViewController: UIViewController, Ticker, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CVDetectorDelegate {

    @IBOutlet var labelCountdown:UILabel
    var countdown: CountdownTimerModel?
    var detector: CVDetectorViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // start countdown
        let totalTime:Double = 3
        self.labelCountdown.center = self.view.center
        self.labelCountdown.text = String(Int(totalTime))
        self.countdown = CountdownTimerModel(initialTime:totalTime, delegate:self)
        self.countdown?.startCountdown()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController.navigationBar.hidden = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // Ticker delegate
    func Tick(timeLeft:Double) {
        NSLog("Tick: \(timeLeft)")
        self.labelCountdown.text = String(Int(timeLeft))
    }

    func Timeout() {
        NSLog("Done")
        self.labelCountdown.text = "Starting camera..."

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            var detector = CVDetectorViewController()
            detector.delegate = self
            self.detector = detector
            self.presentViewController(detector, animated: true, completion: { _ in
            })
        }
        else {
            NSLog("Must have camera-enabled device")
        }
    }

    // delegate
    func motionTriggered() {
        self.dismissViewControllerAnimated(true, completion: { _ in
            self.labelCountdown.text = "Motion triggered!"
            self.detector = nil
            })
    }
}
