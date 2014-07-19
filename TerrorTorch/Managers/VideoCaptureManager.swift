//
//  VideoCaptureManager.swift
//  TerrorTorch
//
//  Created by Shawn on 7/15/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

class VideoCaptureManager{
    
    let session = AVCaptureSession(); //Manages data between input and output
    let output = AVCaptureMovieFileOutput(); //Manages output of video feed data
    var delegate:AVCaptureFileOutputRecordingDelegate? //Notified of when recording starts and stops
    
    init(position:AVCaptureDevicePosition){
        
        //Obtain proper device and configure capture session//Iterate through avaiable capture devices
            
        if let device = VideoCaptureManager.getDevice(AVMediaTypeVideo, position: position){
            if(VideoCaptureManager.addInputTo(session, usingDevice: device) == false){
                println("Faled to add video input");
            }
        }
            
        if let device = VideoCaptureManager.getDevice(AVMediaTypeAudio, position: position){
            if(VideoCaptureManager.addInputTo(session, usingDevice: device) == false){
                println("Failed to add audio input");
            }
        }
        
        
        (session.canAddOutput(output)) ? session.addOutput(output) : println("Cannot add AV output");
        
        //AVCaptureSession Configuration
        session.sessionPreset = AVCaptureSessionPresetMedium;
    }
    
    func startRecordingToPath(path:String){
        if(!session.running){
            let url = NSURL(fileURLWithPath: path);
            let manager = NSFileManager.defaultManager();
        
            //Attempt to delete file if file by that name already exists
            if(manager.fileExistsAtPath(path)){
                var error:NSError?
                if(manager.removeItemAtPath(path, error: &error)){
                    println("Deleted file \(url.lastPathComponent)");
                
                } else {
                    println("Unable to delete \(url.lastPathComponent): \(error)");
                    return;
                }
            }
        
            //Start session, then start recording
            session.startRunning();
            output.startRecordingToOutputFileURL(url, recordingDelegate: delegate);
            println("Started recording to: \(url)");
        }
    }
    
    func endRecording(){
        if(session.running){
            output.stopRecording();
            session.stopRunning()
            println("Stopped recording camera feed");
            
        }
    }
    
    class func addInputTo(session:AVCaptureSession, usingDevice device:AVCaptureDevice) -> AVCaptureDeviceInput?{
        var error:NSError?
        
        if let input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as? AVCaptureDeviceInput{ //Attempt to create input for camera
            //self.videoInput = input;
            if(session.canAddInput(input)){
                session.addInput(input);
                return input;
            } else {
                println("Session is unable to add that kind of input");
            }
            
            
        } else {
            println("Error setting up input for session: \(error!)");
        }
        
        return nil;
    }
    
    class func getDevice(type:String, position:AVCaptureDevicePosition) -> AVCaptureDevice?{
        println("Searching for compatible AV device of type \(type)");
        for device in AVCaptureDevice.devices() as [AVCaptureDevice]{ //Iterate through avaiable capture devices
            if(device.hasMediaType(type) && device.position == position){
                return device;
            }
        }
        return nil;
    }
}