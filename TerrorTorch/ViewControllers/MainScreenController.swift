//
//  ViewController.swift
//  TerrorTorch
//
//  Created by ben on 6/17/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit
import AVFoundation

class MainScreenController: UIViewController {
                            
    @IBOutlet var powerView: UIImageView = nil;
    
    var _device : AVCaptureDevice?
    var isTorchOn = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        
        //Gesture recognizer for transition to settings page
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("presentSettingsScreen:"));
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Left;
        self.view.addGestureRecognizer(swipeRecognizer);
        
        //Don't add gesture recognizer to handle user interactions if device doesn't support torch mode
        //There should also be some kind of UI change to signify it's disabled.
        //Torch mode isn't supported on iOS simulator
        if let dvc = _device {
            if(!dvc.hasTorch) {
                powerView.userInteractionEnabled = true;
                
                //Gesture recognizer for enabling torch mode
                let singleTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("toggleTorchLight:"));
                powerView.addGestureRecognizer(singleTapRecognizer);
                
                // use circular gesture to adjust torch intensity
                let circularRecognizer:UICircularGestureRecognizer = UICircularGestureRecognizer(target: self, action: "rotated:");
                powerView.addGestureRecognizer(circularRecognizer);
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController.navigationBar.hidden = true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       // Dispose of any resources that can be recreated.
    }

    func presentSettingsScreen(recognizer: UISwipeGestureRecognizer){
        if(recognizer.state == UIGestureRecognizerState.Ended){ //Had to cast to raw because equality wasn't working
            self.performSegueWithIdentifier("mainToSettings", sender: self);
        }
    }
    
    func toggleTorchLight(recognizer: UITapGestureRecognizer) {
        if(recognizer.state == UIGestureRecognizerState.Ended){
            if let dvc = _device{
                dvc.lockForConfiguration(nil);
                dvc.torchMode = (isTorchOn) ? AVCaptureTorchMode.Off : AVCaptureTorchMode.On;
                dvc.unlockForConfiguration();
            }
        }
    }

    func brightnessValueChanged(sender: UISlider) {
        if let dvc = _device{
            dvc.setTorchModeOnWithLevel(sender.value, error: nil)
        }
    }
    
    func rotated(recognizer: UICircularGestureRecognizer) {
        NSLog("Degree: %f", recognizer.rotation);
        UICircularGestureRecognizer.rotateView(recognizer);
        
        // TODO: calculate brightness based on rotation
        // possibly limit rotation to a certain min/max degree
    }
}
