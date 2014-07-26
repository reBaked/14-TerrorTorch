//
//  CaptureViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/18/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

class CaptureViewController: UIViewController, Ticker, CVDetectorDelegate, AVCaptureFileOutputRecordingDelegate{
    @IBOutlet var labelCountdown: UILabel!
    
    var cameraPosition = AVCaptureDevicePosition.Front;
    
    private var _countdown = 3.0
    private var _duration = 10.0
    private var _timer:CountdownTimerModel
    private var _captureManager:VideoCaptureManager
    private var _motionDetector:CVDetectorViewController
    
    init(coder aDecoder: NSCoder!) {
        _timer = CountdownTimerModel(initialTime: _countdown);
        _captureManager = VideoCaptureManager(aPosition: cameraPosition, aSession: nil);
        _motionDetector = CVDetectorViewController();
        super.init(coder: aDecoder);
        
        _timer.delegate = self;
        _motionDetector.delegate = self;
        _captureManager.delegate = self;
    }
    
    /**
    *  Time in seconds until motion detection is activated
    *  If value is less than 0, will default to 3.0 seconds
    */
    var timerCountdown:Double{
        set{
            if(newValue > 0){
                _countdown = newValue;
                _timer.timeLeft = _countdown;
            }
        }
        get{
            return _countdown;
        }
    }
    
    /**
    *  Duration of recording once motion detection is detected
    *  If value is less than 0, will default to 10.0 seconds
    */
    var recordDuration:Double{
        set{
            if(newValue > 0){
                _duration = newValue;
            }
        }
        get{
            return _duration;
        }
    }

    var captureManager:VideoCaptureManager{
        get{
            return _captureManager;
        }
    }
    
    var timer:CountdownTimerModel{
        get{
            return _timer;
        }
    }
    
    
    var motionDetector:CVDetectorViewController{
        get{
            return _motionDetector;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        labelCountdown.text = String(Int(timerCountdown));
        timer.startCountdown();
    }
    
    //MARK: Ticker Delegate
    func Tick(timeLeft:Double) {
        println("Tick: \(timeLeft)");
        labelCountdown.text = String(Int(timeLeft))
    }
    
    func Timeout() {
        println("Countdown complete");
        labelCountdown.text = "Starting camera..."
        self.presentViewController(motionDetector, animated: false, completion: nil);
    }
    
    //MARK: CVDetectorDelegate
    func motionTriggered() {
        println("Motion Triggered");
        labelCountdown.text = "Motion triggered!";
        self.dismissViewControllerAnimated(true, completion: { //Dismiss motion detector
            self.startRecording();
        });
    }
    
    //MARK: VideoCaptureManager Actions
    func startRecording(){
        let outputPath = NSTemporaryDirectory() + NSDate(timeIntervalSinceNow: 0).description + ".mov"; //NSDate will probaby need to be formated to something nice.
        
        captureManager.startRecordingToPath(outputPath)
        NSTimer.scheduledTimerWithTimeInterval(_duration, target: self, selector: Selector("endRecording"), userInfo: nil, repeats: false);//Schedule when to end recording
    }
    
    func endRecording(){
        captureManager.endRecording();
        self.dismissViewControllerAnimated(false, completion: nil);
    }
    
    //MARK: AVCaptureFileOutputRecording Delegate
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        println("Camera began recording to file: \(fileURL.lastPathComponent)");
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        println("Camera stopped recording");
        if(error){
            println("Error recording: \(error.localizedDescription)");
        }
    }
    
}