//
//  VideoCaptureManager.swift
//  TerrorTorch
//
//  Created by Shawn on 7/15/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

class VideoCaptureManager{
    
    private var _session    = VideoCaptureManager.getFullAVCaptureSession(AVCaptureDevicePosition.Front)!;   //Manages data between input and output
    private let _output     = AVCaptureMovieFileOutput();                   //Writes data to file
    private var _position   = AVCaptureDevicePosition.Front;                //Position of camera used to capture feed
    
    var delegate:AVCaptureFileOutputRecordingDelegate? //Notified of when recording starts and stops
    
    /**
    *  Will default to creating a session using devices found at the front of the gadget
    *  If a session with a video input cannot be made, then trying to
    *  record the capture session will cause the app to crash
    */
    init(aPosition:AVCaptureDevicePosition?){
        if let position = aPosition{
            _position = position;
        }
        
        _session.addOutput(_output);
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
                    println("Cannot record to that path");
                    return;
                }
            }
            
            //Check if there's a valid session. If not, try to create a new one
            if(!VideoCaptureManager.isValidSession(_session)){
                println("Invalid capture session, attempting to create new one");
                if let aSession = VideoCaptureManager.getFullAVCaptureSession(_position){
                    _session = aSession;
                } else {
                    println("Error: Was unable to create a valid capture session");
                    return;
                }
            }
            
            println("Configuring output of capture session");
            self.configureOutput();
            println("Starting capture session and will begin recording");
            _session.startRunning();
            _output.startRecordingToOutputFileURL(url, recordingDelegate: delegate);
        }
    }
    
    /**
    *  Stop writing data to output and stop capture session
    */
    
    func endRecording(){
        if(_session.running){
            println("Stopping capture session and will end recording");
            _output.stopRecording();
            _session.stopRunning()
        }
    }
    
    func configureOutput(){
        _output.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = VideoCaptureManager.videoOrientationFromDeviceOrientation();
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
                }
            }
            return hasVideo;
        } else {
            return false;
        }
    }
    
    class func videoOrientationFromDeviceOrientation() -> AVCaptureVideoOrientation{
        switch(UIDevice.currentDevice().orientation){
            case UIDeviceOrientation.LandscapeLeft:
                return AVCaptureVideoOrientation.LandscapeRight;
            case UIDeviceOrientation.LandscapeRight:
                return AVCaptureVideoOrientation.LandscapeLeft;
            case UIDeviceOrientation.Portrait:
                return AVCaptureVideoOrientation.Portrait;
            case UIDeviceOrientation.PortraitUpsideDown:
                return AVCaptureVideoOrientation.PortraitUpsideDown;
            default:
                return AVCaptureVideoOrientation.Portrait;
        }
    }   
}