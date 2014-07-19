//
//  TMViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 6/30/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AssetsLibrary

protocol Ticker {
    func Tick(timeLeft:Double)
    func Timeout()
}

class CountdownTimerModel:NSObject{
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

class TMViewController: UIViewController, Ticker, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CVDetectorDelegate, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet var labelCountdown:UILabel
    var videoRecordLayer:AVCaptureVideoPreviewLayer?
    
    
    var _captureManager:VideoCaptureManager?
    var countdown: CountdownTimerModel!
    var detector: CVDetectorViewController?
    var cameraPosition = AVCaptureDevicePosition.Front //Should be set by user
    var recordDuration = 2.0 //Should be set by user user

    var countdownTime:Double{
        set {
            self.countdown.timeLeft = newValue;
        }
        get {
            return self.countdown.timeLeft;
        }
    }
    
    func captureManager() -> VideoCaptureManager{
        if(!_captureManager){
            _captureManager = VideoCaptureManager(position: self.cameraPosition);
            _captureManager!.delegate = self;
        }
        return _captureManager!;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // start countdown
        let totalTime:Double = 3
        self.labelCountdown.center = self.view.center
        self.labelCountdown.text = String(Int(totalTime))
        self.countdown = CountdownTimerModel(initialTime:totalTime, delegate:self)
        self.countdown.startCountdown()
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
            
            //Preview layer for video feed
            self.videoRecordLayer = AVCaptureVideoPreviewLayer(session: self.captureManager().session);
            //Configure layer
            let layerRect = self.view.layer.bounds;
            self.videoRecordLayer!.bounds = layerRect;
            self.videoRecordLayer!.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
            self.videoRecordLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.videoRecordLayer!.backgroundColor = COLOR_WHITE.CGColor;
            
            //Add layter to view, add view to contoller's view and send to back
            let cameraView = UIView(frame: layerRect);
            cameraView.layer.addSublayer(self.videoRecordLayer);
            self.view.addSubview(cameraView);
            self.view.sendSubviewToBack(cameraView);
            
            //Start recording
            let outputPath = NSTemporaryDirectory() + NSDate(timeIntervalSinceNow: 0).description + ".mov"; //NSDate will probaby need to be formated to something nice.
            self.captureManager().startRecordingToPath(outputPath);
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("endRecording"), userInfo: nil, repeats: false);
            })
    }
    
    func endRecording(){
        self.captureManager().endRecording();
    }

    //AVCaptureFileOutputRecordingDelegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        println("Camera recording");
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        println("Camera done recording");
    }


}
