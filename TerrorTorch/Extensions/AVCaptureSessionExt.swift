//
//  AVCaptureSession.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/18/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import Foundation
import AVFoundation

extension AVCaptureSession{
    
    func getInput(mediaType:String) -> AVCaptureDeviceInput?{
        if(self.inputs.isEmpty){
            return nil;
        }
        
        for input in self.inputs as [AVCaptureDeviceInput]{
            if(input.device.hasMediaType(mediaType)){
                return input;
            }
        }
        return nil;
    }
    
}