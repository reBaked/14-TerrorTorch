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
    var soundID:SystemSoundID = 0;
    
    private var _countdown = 3.0
    private var _duration = 10.0
    private var _firstAppearance = true;
    private var _timer = CountdownTimerModel(initialTime: 3.0);
    private var _recordingTimer:NSTimer!
    private var _captureManager:VideoCaptureManager!
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder);
        _timer.delegate = self;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        labelCountdown.text = String(Int(timerCountdown));
    }
    override func viewDidAppear(animated: Bool) {
        if(self._firstAppearance){
            println("Starting countdown...");
            self.timer.startCountdown();
            self._firstAppearance = false;
        }
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
    
    //MARK: Ticker Delegate
    func Tick(timeLeft:Double) {
        labelCountdown.text = String(Int(timeLeft))
    }
    
    func Timeout() {
        println("Countdown complete, starting motion detector");
        labelCountdown.text = "Starting camera..."
        let motionDetector = CVDetectorViewController();
        motionDetector.cameraPosition = self.cameraPosition;
        motionDetector.delegate = self;
        self.presentViewController(motionDetector, animated: false, completion: nil);
    }
    
    //MARK: CVDetectorDelegate
    func motionTriggered() {
        println("Motion captured, dismissing motion detector");
        labelCountdown.text = "Motion triggered!";
        self.dismissViewControllerAnimated(true, completion: { //Dismiss motion detector
            dispatch_async(dispatch_get_main_queue()){
                self._captureManager = VideoCaptureManager(aPosition: self.cameraPosition);
                self._captureManager.delegate = self;
                self.startRecording();
                println("Started recording camera feed");

            }
        });
        
        AudioServicesPlaySystemSound(self.soundID);
    }
    
    //MARK: VideoCaptureManager Actions
    func startRecording(){
        let outputPath = NSTemporaryDirectory() + NSDate(timeIntervalSinceNow: 0).description + ".mov"; //NSDate will probaby need to be formated to something nice.
        
        _captureManager.startRecordingToPath(outputPath)
        //_recordingTimer = NSTimer(timeInterval: 4.0, target: self, selector: Selector("endRecording"), userInfo: nil, repeats: true);
        NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("endRecording"), userInfo: nil, repeats: false);
    }
    
    //Called when NSTimer:_duration ends
    func endRecording(){
        _captureManager.endRecording();
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
