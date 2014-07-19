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
    @IBOutlet var labelCountdown: UILabel
    
    var cameraPosition = AVCaptureDevicePosition.Front;
    var timerCountdown = 3.0;
    var recordDuration = 10.0;

    var _captureManager:VideoCaptureManager!
    let _timer = CountdownTimerModel(initialTime: 3, delegate: nil);
    let _motionDetector = CVDetectorViewController();
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        _timer.delegate = self;
        _motionDetector.delegate = self;
        _motionDetector.cameraPosition = self.cameraPosition;
        
        
    }
    
    func startRecording(){
        let outputPath = NSTemporaryDirectory() + NSDate(timeIntervalSinceNow: 0).description + ".mov"; //NSDate will probaby need to be formated to something nice.
        
        self._captureManager.startRecordingToPath(outputPath)
        
        
        NSTimer.scheduledTimerWithTimeInterval(self.recordDuration, target: self, selector: Selector("endRecording"), userInfo: nil, repeats: false);//Schedule when to end recording
    }

    func endRecording(){
        _captureManager.endRecording();
        self.navigationController.popViewControllerAnimated(false);
    }
    
    //MARK: Ticker Delegate
    func Tick(timeLeft:Double) {
        println("Tick: \(timeLeft)");
        self.labelCountdown.text = String(Int(timeLeft))
    }
    
    func Timeout() {
        println("Countdown complete");
        self.labelCountdown.text = "Starting camera..."
        self.presentViewController(_motionDetector, animated: false, completion: nil);
    }
    
    //MARK: CVDetectorDelegate
    func motionTriggered() {
        
        self.dismissViewControllerAnimated(true, completion: { //Dismiss motion detector
            self.labelCountdown.text = "Motion triggered!"
            self.startRecording();
            });
        
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
