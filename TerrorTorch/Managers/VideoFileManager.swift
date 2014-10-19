//
//  VideoFileManager.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 10/18/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import Foundation

struct VideoFileManager{
    static var fileURLs:[NSURL] = [];
    static var images:[UIImage] = [];
    
    static let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    
    static func generateImages(onCompletion: () -> ()){
        let fileManager = NSFileManager();
        let paths = fileManager.contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);
        let tmpDirectory = NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);

        for file in tmpDirectory as [String]{
            if(file.pathExtension == "mov"){
                let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + file);
                fileURLs.append(fileURL);
            }
        }
        
        
        for (i, URL) in enumerate(fileURLs){
            let asset = AVURLAsset(URL: URL, options: nil);
            let generator = AVAssetImageGenerator(asset: asset);
            let thumbTime = CMTimeMakeWithSeconds(4, 30);
            let maxSize = CGSizeMake(320, 180);
                
            println("Generating thumbnail for file: \(URL.lastPathComponent)");
            generator.appliesPreferredTrackTransform=true;
            generator.maximumSize = maxSize;
            
            dispatch_async(queue){
                generator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime:thumbTime)]){ (requestedTime, im, actualTime, result, error)  in
                    if(result != AVAssetImageGeneratorResult.Succeeded){
                        println("Couldn't generate thumbnail for file: \(URL.lastPathComponent)");
                    } else {
                        self.images.append(UIImage(CGImage: im));
                    }
                    if(i == self.fileURLs.count-1){
                        
                        dispatch_sync(dispatch_get_main_queue()){
                            onCompletion();
                        }
                    }
                }
            }
        }
    }
}