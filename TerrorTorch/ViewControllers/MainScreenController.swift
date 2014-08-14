//
//  ViewController.swift
//  TerrorTorch
//
//  Created by ben on 6/17/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

class MainScreenController: UIBaseViewController {
                            
    @IBOutlet var powerView: UIImageView! = nil;
    
    private var _torchDevice:AVCaptureDevice?;
    private var _isTorchOn = false;
    private var _defaultScreenBrightness:CGFloat!;
    
    var knobAngle:Float = 0.0;
    var torchLevel:Float = 0.5;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _defaultScreenBrightness = UIScreen.mainScreen().brightness; //Used to restore original user defined brightness settings
        
        //Get all devices that support torch mode
        for device in AVCaptureDevice.devices() as [AVCaptureDevice]{
            if(device.hasTorch){
                _torchDevice = device;
                break;
            }
        }
        
        //User circular gesture to adjust torch intensity
        let circularRecognizer:UICircularGestureRecognizer = UICircularGestureRecognizer(target: self, action: "rotated:");
        powerView.addGestureRecognizer(circularRecognizer);
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        if(_isTorchOn){
            turnTorchLightOn(false);
        }
    }

    /**
    *  Called when user swipes to the right
    */    
    @IBAction func presentSettingsScreen(sender: UISwipeGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended){ //Had to cast to raw because equality wasn't working
            self.performSegueWithIdentifier("mainToSettings", sender: self);
        }

    }
    /**
    *  Called when user taps on power view
    *  Toggles torch light and set's intesity to previous intesity level
    */
    @IBAction func toggleTorchLight(sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizerState.Ended) {
            turnTorchLightOn(!_isTorchOn);
        }
        
        if(_isTorchOn) {
            self.changeTorchIntensity(self.torchLevel);
        }
    }
    
    /**
    *  Enables/Disables torch mode or mimics by increasing screen brightness
    */
    func turnTorchLightOn(turnOn:Bool){
        if(_isTorchOn == turnOn) { return; }
        if let dvc = _torchDevice{
            dvc.lockForConfiguration(nil);
            dvc.torchMode = (turnOn) ? AVCaptureTorchMode.On : AVCaptureTorchMode.Off;
            dvc.unlockForConfiguration();
        } else {
            if(turnOn){
                self.view.backgroundColor = UIColor.whiteColor();
            } else {
                self.view.backgroundColor = UIColor.blackColor();
                UIScreen.mainScreen().brightness = _defaultScreenBrightness;
            }
        }
        
        _isTorchOn = turnOn;
    }

    /**
    *  Changes the torch level/intensity
    *
    *  @param intensity:Float A float value between 0.1 and 1.0
    */
    func changeTorchIntensity(intensity:Float) {
        if(_isTorchOn){
            self.torchLevel = (intensity > 0.0 && intensity <= 1.0) ? intensity : 0.01;
            NSLog("Setting intesity level to: %f", self.torchLevel);
            
            if let dvc = _torchDevice{
                dvc.lockForConfiguration(nil);
                dvc.setTorchModeOnWithLevel(self.torchLevel, error: nil)
                dvc.unlockForConfiguration();
            } else {
                UIScreen.mainScreen().brightness = CGFloat(self.torchLevel);
            }
        }
    }
    
    /**
    *   Action for "knob" control rotate gesture
    */
    func rotated(recognizer: UICircularGestureRecognizer) {
        var currentAngle:Float = 0.0;
        if _isTorchOn && self.shouldAllowRotation(recognizer.rotation, currentAngle:&currentAngle, minAngle:-90, maxAngle:90) {
            UICircularGestureRecognizer.rotateView(recognizer);
            self.changeTorchIntensity(self.calculateIntensity(currentAngle));
        }
    }
    
    /**
    *  Calculates intensity based on ratio for min/max angles allowed by "knob" control
    *
    *  @param currentAngle:Float The current angle of the "knob" control
    *  @return Float - Returns a float value between 0.1 and 1.0
    */
    func calculateIntensity(currentAngle:Float) -> Float {
        let boundedCurrentAngle:Float = governFloat(currentAngle);
        
        // this method assumes a range of -90 to 90, otherwise math needs to be tweaked
        assert((Int(boundedCurrentAngle) >= -90 && Int(boundedCurrentAngle) <= 90), "Expects a value between -90 and 90");
        
        let angle:Float = (((boundedCurrentAngle < 0) ? floorf(boundedCurrentAngle) : ceilf(boundedCurrentAngle)) + 90); // produces 0 - 180
        let intensity:Float = (angle / 1.8) / 100.0;
        return ceilf(intensity * 100) / 100;
    }
    
    /**
    *  Correct erroneous float values by limiting it to a desired range.
    *
    *  @param currentFloat:Float The float that requires potential correcting
    *  @param max:Float [optional] Defaults to -90.0
    *  @param min:Float [optional] Defaults to 90.0
    *  @return Float Returns currentFloat if within range, max if above range, min if below range.
    */
    func governFloat(currentFloat:Float, min:Float = -90.0, max:Float = 90.0) -> Float {
        switch currentFloat {
        case let x where x < min:
            return min;
        case let x where x > max:
            return max;
        default:
            return currentFloat;
        }
    }
    
    /**
    *  Determines if "knob" control's current rotation falls within min/max degrees
    *
    *  @param currentRadians:Float The current angle of the "knob" control in radians
    *  @param inout currentAngle:Float Will contain the calculated angle of the "knob" control
    *  @param maxAngle:Float [optional] - Defaults to -90.0
    *  @param minAngle:Float [optional] - Defaults to 90.0
    *  @return Bool - Returns true if within min/max, false otherwise
    */
    func shouldAllowRotation(currentRadians:Float, inout currentAngle:Float, minAngle:Float = -90.0, maxAngle:Float = 90.0) -> Bool {
        let degrees = UICircularGestureRecognizer.radiansToDegrees(currentRadians);
        currentAngle = self.knobAngle + degrees;
        let newAngle:Float = fmodf(currentAngle, 360.0);
        
        var shouldRotate = false;
        if minAngle <= maxAngle {
            shouldRotate = (newAngle >= minAngle && newAngle <= maxAngle) ? true : false;
        } else if minAngle > maxAngle {
            shouldRotate = (newAngle >= minAngle || newAngle <= maxAngle) ? true : false;
        }
        
        if shouldRotate {
            self.knobAngle = newAngle;
        }
        return shouldRotate;
    }
    
    @IBAction func clearCachePressed(sender: UIButton) {
        
        let tmpDirectory = NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);
        
        for file in tmpDirectory as [String]{
            NSFileManager.defaultManager().removeItemAtPath(NSTemporaryDirectory() + file, error: nil);
        }
    }
}
