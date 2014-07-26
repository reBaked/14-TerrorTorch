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


class TMViewController: UIBaseViewController{
    
    @IBOutlet var videoFeedView: UIView!
    @IBOutlet var sgmtCameraPosition: UISegmentedControl!
    @IBOutlet var sgmtCountdownTime: UISegmentedControl!
    @IBOutlet var startButton: UIButton!

    
    private var _hasPermissions = false;
    private var _hasValidSession = false;
    private var _session:AVCaptureSession!
    private var _previewLayer:AVCaptureVideoPreviewLayer!
    
    //MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoFeedView.layer.addSublayer(self._previewLayer);
        
        // Do any additional setup after loading the view.
        println("Requesting permission to use AV devices");
        
        self.requestAVPermissions(completion: {
            println("AV permissions have been set");
            if($0){
                println("Setting up initial configuration for capture session");
                self.setInitialConfigurationForSession();
            } else{
                println("Inadequate AV permissions");
                self.startButton.enabled = false;
            }
        });
        
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkSession"), userInfo: nil, repeats: false);
    }
    
    func checkSession(){
        if(self._hasValidSession == false){
            let alertView = UIAlertView(title: "Invalid device", message: "This device does not meet the minimum requirements to run TerrorTorch mode", delegate: nil, cancelButtonTitle: "Ok");
            alertView.show();
            self.videoFeedView.alpha = 0.0;
        }
    }

    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated);
        if(_session){
            println("Configuring preview layer");
            self.configurePreviewLayer();
            println("Starting capture session");
            self._session.startRunning();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        _session.stopRunning();
        
        if let controller = segue.destinationViewController as? CaptureViewController{
            controller.cameraPosition = self.getCameraPosition();
            controller.timerCountdown = self.getCountdownTime();
            controller.recordDuration = 4;
        }
    }
    
    //MARK: IBActions
    @IBAction func cameraPositionChanged(sender: UISegmentedControl) {
        if(_session){
            _session.beginConfiguration();
            if let device = VideoCaptureManager.getDevice(AVMediaTypeVideo, position: self.getCameraPosition()){
            
                if let currentInput = _session.getInput(AVMediaTypeVideo){
                    _session.removeInput(currentInput);
                } else {
                    println("No video input found in session while changing camera position");
                }
            
                if let input = VideoCaptureManager.addInputTo(_session, usingDevice: device){
                    println("Successfully changed position of camera");
                } else {
                    println("Failed to change positon of camera");
                }
            } else {
                println("Device does not support that camera position");
            }
            _session.commitConfiguration();
        }
    }
    
    //MARK: Queries
    
    /**
    *  Retrieves then converts value of sgmCameraPosition
    */
    func getCameraPosition() -> AVCaptureDevicePosition{
        switch(sgmtCameraPosition.selectedSegmentIndex){
            case 1:
                return AVCaptureDevicePosition.Back;
            default:
                return AVCaptureDevicePosition.Front;
        }
    }
    
    /**
    *  Retrieves then convers value of sgmtCountdownTime
    */
    func getCountdownTime() -> Double{
        switch(sgmtCountdownTime.selectedSegmentIndex){
            case 1:
                return 15.0;
            case 2:
                return 30.0;
            case 3:
                return 60.0;
            case 4:
                return 180.0;
            case 5:
                return 300.0;
            default:
                return 3.0;
        }
    }
    
    //MARK: Configurations
    
    /**
    *  Changes frame of preview layer to match and fill outlet view
    */
    func configurePreviewLayer(){
        if(_previewLayer){
            let layerRect = self.videoFeedView.layer.bounds;
            _previewLayer.bounds = layerRect;
            _previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
            _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        }
    }

    /**
    *   Adds video input to capture session and defaults to front camera
    */
    func setInitialConfigurationForSession(){
        
        if let aSession = VideoCaptureManager.getFullAVCaptureSession(AVCaptureDevicePosition.Front){
            _session = aSession;
            _previewLayer = AVCaptureVideoPreviewLayer(session: _session);
            _hasValidSession = true;
        } else {
            println("Failed to create a valid session to preview capture session. Will not be able to record");
            startButton.enabled = false;
        }
    }
    
    //MARK: User Settings
    
    /**
    *   Checks to see if app has been given permission to microphone and camera
    *   If not, ask for permission.
    */
    func requestAVPermissions(completion callback: (Bool) -> ()){
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
            if($0){
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeAudio, completionHandler: {
                    if($0){
                        self._hasPermissions = true;
                    } else {
                        println("Denied use of Microphone");
                    }
                    callback(self._hasPermissions);
                })
            } else {
                println("Denied use of camera");
            }
        });
    }
    
}
