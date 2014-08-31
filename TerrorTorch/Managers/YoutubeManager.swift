//
//  YoutubeManager.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 8/16/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import Foundation

struct YoutubeManager{
    
    static let Part = "id%2C+snippet";
    static let ChannelID = "UCg-Hnkjq8eVT9CSSoot01uw";
    static let APIKey = "AIzaSyDU_5S6VMcAWdOmlq039dNAK2LYvA38WhA";
    static let SearchBase = "https://www.googleapis.com/youtube/v3/search?";
    static let WatchVideoBase = "http://www.youtube.com/watch?v=";
    
    static var videoIDs:[String]!;
    static var imageURLs:[String]!;
    static var images:[UIImage]!;
    static var doneWithRequest = true;
    
    static private let queue = dispatch_queue_create("com.reBaked.Youtube", nil);
    
    static func getVideoURLForIndexPath(indexPath:NSIndexPath) -> String?{
        if(indexPath.item > videoIDs.count) { return nil; }
        
        return WatchVideoBase + videoIDs[indexPath.item];
    }
    
    static func getVideoSnippets(maxCount:Int, completionHandler:((videoIDs:[String]!, imageURLs:[String]!) -> ())?){
        if(maxCount <= 0) { return; }
        var snippetsLeft = maxCount;
        var resultImageURLs:[String] = [];
        var resultVideoIDs:[String] = [];
        self.doneWithRequest = false;

        dispatch_async(queue){
            println("Sending request to youtube command: GETVideoSnippets channelId: \(self.ChannelID) maxCount:\(maxCount)");
            var iteration = 0;
            while(snippetsLeft > 0){
                print("GETVideoSnippets iteration \(iteration): ");
                let maxResults = (snippetsLeft > 50) ? 50 : snippetsLeft;
                snippetsLeft =- 50;
                
                let URLString =  self.SearchBase + "part=" + self.Part + "&channelId=" + self.ChannelID + "&maxResults=\(maxResults)&key=" + self.APIKey + "&type=video";
                let request = NSURLRequest(URL: NSURL(string: URLString));
                
                var error:NSError?
                let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: &error)
                
                if(error == nil){
                    let JSON = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as [String:AnyObject];
                    
            
                    if let responseError:AnyObject = JSON["error"]{
                        print("Failed with error: ");
                        print(responseError["code"]!);
                        print(" ");
                        print(responseError["message"]!);
                    } else {
                        for item in JSON["items"]! as [[String:AnyObject]]{
                            let videoId = (item["id"]!)["videoId"]! as String;

                            let thumbnails = (item["snippet"]!)["thumbnails"]! as [String:AnyObject];
                            let imageURL = (thumbnails["high"]!)["url"]! as String;
                            resultVideoIDs.append(videoId);
                            resultImageURLs.append(imageURL);
                        }
                    }
                    print("Success")
                } else {
                    print("Failed with error: \(error!.localizedDescription)");
                }
                print("\n");
            }
            
            self.videoIDs = (resultVideoIDs.isEmpty) ? nil : resultVideoIDs;
            self.imageURLs = (resultImageURLs.isEmpty) ? nil : resultImageURLs;
            dispatch_sync(dispatch_get_main_queue()){
                if let handler = completionHandler{
                    handler(videoIDs: self.videoIDs, imageURLs: self.imageURLs);
                }
            }
        }
    }
    
    static func fetchImagesFromURLs(completionHandler:((images:[UIImage]!) -> ())?){
        var resultImages:[UIImage] = [];
        
        dispatch_async(queue){
            println("Attempting to download \(self.imageURLs.count) images for terror gallery");
            for (index, URLString) in enumerate(self.imageURLs!){
                let request = NSURLRequest(URL: NSURL(string: URLString));
                
                var error:NSError?
                let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: &error);
                
                if(error == nil){
                    let image = UIImage(data: data);
                    resultImages.append(image);
                } else {
                    println("Download image \(index) failed with error: \(error)");
                }
            }
            println("Finished downloading images");
            self.images = (resultImages.isEmpty) ? nil : resultImages;
            dispatch_sync(dispatch_get_main_queue()){
                if let handler = completionHandler{
                    handler(images: self.images);
                }
            }
        }
    }
    
    static func playVideoAtIndexPath(indexPath:NSIndexPath){
        println(indexPath);
        UIApplication.sharedApplication().openURL(NSURL(string:"" + self.videoIDs[indexPath.item]));
    }
}
