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
    let videoInput:AVCaptureDeviceInput! //Manages camera ports
    let audioInput:AVCaptureDeviceInput! //Manages audio ports///
    let camera:AVCaptureDevice! //MAnaged camera device
    var delegate:AVCaptureFileOutputRecordingDelegate? //Notified of when recording starts and stops
    var isRecording = false;
    
    init(position:AVCaptureDevicePosition, totalDuration:Double, framesPerSecond:Int){
        
        //Obtain proper device and configure capture session
        for device in AVCaptureDevice.devices() as [AVCaptureDevice]{ //Iterate through avaiable capture devices
            if(device.hasMediaType(AVMediaTypeVideo) && device.position == position){ //Must be video and match the position  of CVDetection
                camera = device;
                var error:NSError?
                
                if let videoInput = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as? AVCaptureDeviceInput{ //Attempt to create input for camera
                    (session.canAddInput(videoInput)) ? session.addInput(videoInput) : println("Cannot add video input"); //Attempt to add to capture session
                    
                    //Configure then add output
                    let maxDuration = CMTimeMakeWithSeconds(Float64(totalDuration), Int32(framesPerSecond));
                    output.maxRecordedDuration = maxDuration;
                    output.minFreeDiskSpaceLimit = 1024*1024 //This should be set to some limit on our cache
                    (session.canAddOutput(output)) ? session.addOutput(output) : println("Cannot add video output");
                    
                } else {
                    println("Error setting up input for video: \(error!)");
                }
            }
            
            else if(device.hasMediaType(AVMediaTypeAudio)){
                var error:NSError?
                
                if let audioInput = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as? AVCaptureDeviceInput{
                    (session.canAddInput(audioInput)) ? session.addInput(audioInput) : println("Cannot add audio input");
                }
            }
        }
        
        //AVCaptureSession Configuration
        session.sessionPreset = AVCaptureSessionPresetMedium;
    }
    
    func startRecordingToPath(path:String){
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
        session.startRunning()
        output.startRecordingToOutputFileURL(url, recordingDelegate: delegate);
        println("Started recording to: \(url)");
        self.isRecording = true;
    }
    
    func endRecording(){
        if(isRecording){
            //End session, then stop recording
            output.stopRecording();
            self.isRecording = false;
            session.stopRunning()
            println("Stopped recording camera feed");
        }
    }
}