//
//  TMViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 6/30/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit


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

class TMViewController: UIViewController, Ticker {

    @IBOutlet var labelCountdown:UILabel
    var countdown: CountdownTimerModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // start countdown
        let totalTime:Double = 15
        self.labelCountdown.text = String(totalTime)
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
        self.labelCountdown.text = String(timeLeft)
    }

    func Timeout() {
        NSLog("Done")
        self.labelCountdown.text = "Starting camera"
    }
}
