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
                            
    @IBOutlet var lightToggle : UIButton = nil;
    @IBOutlet var brightnessSlider: UISlider = nil;
    
    var _device : AVCaptureDevice?
    var isTorchOn = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        
        //Disable views pertaining to flashlight if torch mode isn't support
        //Torch mode isn't supported on iOS simulator
        if let dvc = _device {
            if(!dvc.hasTorch) { lightToggle.enabled = false;}
        } else {
            lightToggle.enabled = false;
            brightnessSlider.enabled = false;
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func toggleTorchPressed() {
        if let dvc = _device{
            dvc.lockForConfiguration(nil); //TODO: Resolve possible errors, this can't stay nil
            dvc.torchMode = (isTorchOn) ? AVCaptureTorchMode.Off : AVCaptureTorchMode.On;
            dvc.unlockForConfiguration();
        }
    }

    @IBAction func brightnessValueChanged(sender: UISlider) {
        if let dvc = _device{
            dvc.setTorchModeOnWithLevel(sender.value, error: nil) //TODO: Resolve possible errors
        }
    }
}
