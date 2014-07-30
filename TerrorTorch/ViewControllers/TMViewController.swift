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


class TMViewController: UIBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet var videoFeedView: UIView!
    @IBOutlet var sgmtCameraPosition: UISegmentedControl!
    @IBOutlet var sgmtCountdownTime: UISegmentedControl!
    @IBOutlet var startButton: UIButton!

    
    private var _hasPermissions = false;
    private var _session:AVCaptureSession!
    private var _previewLayer:AVCaptureVideoPreviewLayer!
    
    //MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //print("Requesting permission to use audio devices: ");
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeAudio, completionHandler: { (audioGranted) in
            if(audioGranted){ print("Granted\n"); }
            else {  print("Denied\n");  }
            
            //print("Requesting permission to use video devices: ")
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (videoGranted) in
                if(videoGranted){
                    //print("Granted\n");
                    self._hasPermissions = true;
                } else {
                    //print("Denied\n");
                    self.startButton.enabled = false;
                }
                dispatch_sync(dispatch_get_main_queue()){
                    //println("Setting up default capture session");
                    self.setInitialConfigurationForSession();
                    if(VideoCaptureManager.isValidSession(self._session)){
                        //println("Configuring preview layer");
                        self._previewLayer = AVCaptureVideoPreviewLayer(session: self._session);
                        self.videoFeedView.layer.addSublayer(self._previewLayer);
                        self.configurePreviewLayer();
                        self._session.startRunning();
                    } else {
                        let alertView = UIAlertView(title: "Invalid device", message: "This device does not meet the minimum requirements to run TerrorTorch mode", delegate: nil, cancelButtonTitle: "Ok");
                        alertView.show();
                        self.videoFeedView.alpha = 0.0;
                    }
                }

            });
        });
    }

    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated);
        if(_session){
            println("Starting capture session");
            self._session.startRunning();
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if(_session){ //&& _session.running){
            println("Stopping capture session");
            self._session.stopRunning();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
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
        if(VideoCaptureManager.isValidSession(_session)){
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
        } else {
            println("Failed to create a valid capture session. Disabling TerrorMode");
            startButton.enabled = false;
        }
    }
    
   // func createSoundAssets() -> [SystemSoundID]{
        
   // }
    //MARK: UICollectionView Delegate
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        let soundName = appAssets[indexPath.row]["soundName"]!;
        println(soundName);
        let soundPath = NSBundle.mainBundle().pathForResource(soundName, ofType: "wav");
        let soundURL = NSURL(fileURLWithPath: soundPath);
        var sound:SystemSoundID = 0;
        AudioServicesCreateSystemSoundID(soundURL, &sound);
        AudioServicesPlaySystemSound(sound);
        //AudioServicesDisposeSystemSoundID(sound);
        
    }
    

    //MARK: UICollectionView Datasource
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as UICollectionViewCellStyleImage;
        let height = collectionView.frame.height - 40;
        
        //cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, height, height);
        
        let imageName = appAssets[indexPath.row]["imageName"]!;
        cell.imageView.image = UIImage(named: imageName);
        if(indexPath.item == 0){
            cell.highlighted = true;
        }
        return cell;
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return appAssets.count;
    }
    
}
