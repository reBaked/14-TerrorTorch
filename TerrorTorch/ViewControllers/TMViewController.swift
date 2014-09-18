//
//  TMViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 6/30/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

class TMViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet var videoFeedView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var sgmtCameraPosition: UISegmentedControl!
    @IBOutlet var sgmtCountdownTime: UISegmentedControl!
    @IBOutlet var startButton: UIButton!
    
    let soundPlayer = AVPlayer();
    
    private var _hasPermissions = false;
    private var _session:AVCaptureSession!
    private var _previewLayer:AVCaptureVideoPreviewLayer!
    
    var soundPlayer_ofSelectedItem:AVPlayer{
        get{
            //self.updateSoundPlayer(collectionView.selectedItem!);
            return soundPlayer;
        }
    }
    
    var cameraPosition:AVCaptureDevicePosition{
        get{
            switch(sgmtCameraPosition.selectedSegmentIndex){
            case 1:
                return AVCaptureDevicePosition.Back;
            default:
                return AVCaptureDevicePosition.Front;
            }
        }
    }
    
    var countdownTime:Double{
        get{
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
    }
    //MARK: UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dispatch_async(dispatch_get_main_queue()){
            print("Requesting permission to use audio devices: ");
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeAudio, completionHandler: {
                if($0) { print("Granted\n"); }
                else { print("Denied\n"); }
                
                print("Requesting permission to use video devices: ")
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
                    if($0) {
                        self._hasPermissions = true;
                        print("Granted\n");
                    }
                    else {
                        print("Denied\n");
                    }
                    
                    dispatch_sync(dispatch_get_main_queue()){
                        if(self._hasPermissions){
                            println("Setting up capture session for preview");
                            self.setInitialConfigurationForSession();
                            if(VideoCaptureManager.isValidSession(self._session)){
                                println("Configuring preview layer for camera feed");
                                self._previewLayer = AVCaptureVideoPreviewLayer(session: self._session);
                                self._previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                                self.videoFeedView.layer.addSublayer(self._previewLayer);
                                self.updatePreviewLayer();
                                self.videoFeedView.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.New, context: nil);
                                self._session.startRunning();
                            } else {
                                let alertView = UIAlertView(title: "Invalid device", message: "This device does not meet the minimum requirements to run TerrorTorch mode", delegate: nil, cancelButtonTitle: "Ok");
                                alertView.show();
                                self.disableTerrorMode()
                            }
                        } else {
                            let alertView = UIAlertView(title: "Invalid permissions", message: "Terror Mode must have access to your camera in order to be enabled", delegate: nil, cancelButtonTitle: "Ok");
                            alertView.show();
                            self.disableTerrorMode()
                        }
                    }
                });
            });
        }
    }

    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<()>) {
        if(keyPath == "bounds"){
            self.updatePreviewLayer();
        }
    }
    
    override func viewDidAppear(animated: Bool){
        super.viewDidAppear(animated);
        if(_session != nil){
            println("Starting capture session for preview");
            self._session.startRunning();
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        if(_session != nil){
            println("Stopping capture session for preview");
            self._session.stopRunning();
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        super.prepareForSegue(segue, sender: sender);
        if let controller = segue.destinationViewController as? CaptureViewController{
            controller.cameraPosition = self.cameraPosition;
            controller.timerCountdown = self.countdownTime;
            controller.soundPlayer = self.soundPlayer_ofSelectedItem;
            controller.recordDuration = 5;
        }
    }
    
    //MARK: IBActions
    @IBAction func cameraPositionChanged(sender: UISegmentedControl) {
        if((_session) != nil){
            _session.beginConfiguration();
            if let device = VideoCaptureManager.getDevice(AVMediaTypeVideo, position: self.cameraPosition){
            
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
    
    
    
    //MARK: Configurations
    
    /**
    *  Changes frame of preview layer to match and fill outlet view
    */
    func updatePreviewLayer(){
        if(VideoCaptureManager.isValidSession(_session)){
            
            let layerRect = self.videoFeedView.layer.bounds;
            _previewLayer.bounds = layerRect;
            _previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
            _previewLayer.connection.videoOrientation = VideoCaptureManager.videoOrientationFromDeviceOrientation();
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
    
    func updateSoundPlayer(indexPath:NSIndexPath){
        let soundName = appAssets[indexPath.item]["soundName"];
        let path = NSBundle.mainBundle().pathForResource(soundName, ofType: SOUNDFORMAT)
        let url = NSURL(fileURLWithPath: path!);
        
        soundPlayer.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: url));
    }
    
    func disableTerrorMode(){
        videoFeedView.hidden = true;
        startButton.enabled = false;
        sgmtCameraPosition.enabled = false;
        sgmtCountdownTime.enabled = false;
        println("Terror mode disabled");
    }

    //MARK: UICollectionView Delegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.updateSoundPlayer(indexPath);
        soundPlayer.play();
    }

    //MARK: UICollectionView Datasource
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as UICollectionViewCellStyleImage;
        
        cell.imageView.image = UIImage(named: appAssets[indexPath.row]["imageName"]!);
        return cell;
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appAssets.count;
    }
    

    
    deinit{
        if(_session != nil){
            self.videoFeedView.removeObserver(self, forKeyPath: "bounds");
        }
    }
}
