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
    
    private var _session    = VideoCaptureManager.getFullAVCaptureSession(AVCaptureDevicePosition.Front)!;   //Manages data between input and output
    private let _output     = AVCaptureMovieFileOutput();
    private var _position   = AVCaptureDevicePosition.Front;
    
    var cameraPosition:AVCaptureDevicePosition{
        set{
            _position = newValue;
        }
        get{
            return _position;
        }
    }
    
    var captureSession:AVCaptureSession?{
        get {
            return _session;
        }
    }
    
    var delegate:AVCaptureFileOutputRecordingDelegate? //Notified of when recording starts and stops
    
    /**
    *  Will default to creating a session using devices found at the front of the gadget
    *  If a full session with video and audio capabilities cannot be made, then trying to
    *  record the capture session will cause the app to crash
    */
    init(aPosition:AVCaptureDevicePosition?){
        if(aPosition != nil){
            cameraPosition = aPosition!;
        }
    }
    
    /**
    *   Attempts to delete previous file at path
    *   Starts session and writes data from inputs to path
    *   
    *   @param path:String Path to write output
    */
    func startRecordingToPath(path:String){
        if(!_session.running){
            
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
            
            //Create session, then start recording
            if let aSession = VideoCaptureManager.getFullAVCaptureSession(_position){
                _session = aSession;
                _session.addOutput(_output);
                _session.startRunning();
                println("Started capture session for recording");
                _output.startRecordingToOutputFileURL(url, recordingDelegate: delegate);
                
            } else {
                println("Critical Error: Was unable to create a valid capture session");
            }
        }
    }
    
    /**
    *  Stop writing data to output and stop capture session
    */
    
    func endRecording(){
        if(_session.running){
            _output.stopRecording();
            _session.stopRunning()
            println("Stopped capture session for recording");
            
        }
    }
    
    /**
    *  Safely attempts to add input of device to capture session
    *
    *  @param session:AVCaptureSession Should not already have an input from given device
    *  @param device:AVCaptureDevice
    *
    *  @return Input object that was added to session
    */
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
    
    /**
    *  Returns a session that contains a valid video and audio input for the given position
    *
    *  @param position:AVCaptureDevicePosition Position of device
    *
    *  @return Nil if unable to create a session.
    */
    class func getFullAVCaptureSession(position:AVCaptureDevicePosition) -> AVCaptureSession?{
        let session = AVCaptureSession();
    
        if let device = VideoCaptureManager.getDevice(AVMediaTypeVideo, position: position){
            if(VideoCaptureManager.addInputTo(session, usingDevice: device) == false){
                println("Failed to add video input");
            }
        } else {
            println("Unable to obtain a valid video input");
        }
        
        if let device = VideoCaptureManager.getDevice(AVMediaTypeAudio, position: AVCaptureDevicePosition.Unspecified){
            if(VideoCaptureManager.addInputTo(session, usingDevice: device) == false){
                println("Failed to add audio input");
            }
        } else {
            println("Unable to obtain a valid audio input");
        }
        
        //AVCaptureSession Configuration
        session.sessionPreset = AVCaptureSessionPresetMedium;
        if(VideoCaptureManager.isValidSession(session) == false){
            return nil;
        }
        
        return session;
    }
    
    /**
    *  Iterates through all available devices looking for a match
    *
    *  @param type:String AVMediaVideo, AVMediaAudio or AVMediaMux
    *  @param position:AVCaptureDevicePosition
    *  @return Will return nil if not devices match parameters. 
    */
    class func getDevice(type:String, position:AVCaptureDevicePosition) -> AVCaptureDevice?{
        for device in AVCaptureDevice.devices() as [AVCaptureDevice]{ //Iterate through avaiable capture devices
            if(device.hasMediaType(type) && device.position == position){
                return device;
            }
        }
        return nil;
    }
    
    /**
    *  Determines if given session has minimum requirements for VideoCaptureManager
    *
    *  @param session:AVCaptureSession Can be obtained by calling getFullAVCaptureSession
    *
    *  @return Return true only if session has a valid audio and video input.
    */
    class func isValidSession(aSession:AVCaptureSession?) -> Bool{
        if let session = aSession{
            var hasVideo = false;
            //var hasAudio = false;
            for input in session.inputs as [AVCaptureDeviceInput]{
                if(input.device.hasMediaType(AVMediaTypeVideo)){
                    hasVideo = true;
                }/* else if(input.device.hasMediaType(AVMediaTypeAudio)){
                    hasAudio = true;
                }*/
            }
            return hasVideo;
        } else {
            return false;
        }
    }
}