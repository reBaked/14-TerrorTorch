//
//  VideoUploadViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 9/7/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//
import CoreMedia


class VideoUploadViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var fileURLs:[NSURL] = [];
    var images:[UIImage] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let fileManager = NSFileManager();
        let paths = fileManager.contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);
        let tmpDirectory = NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);
        
        let queue = dispatch_queue_create("com.reBaked.ImageGenerator", nil);
        for file in tmpDirectory as [String]{
            if(file == "MediaCache"){
                continue;
            }
            let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + file)
            let asset = AVURLAsset(URL: fileURL, options: nil);
            let generator = AVAssetImageGenerator(asset: asset);
            let thumbTime = CMTimeMakeWithSeconds(4, 30);
            let maxSize = CGSizeMake(320, 180);
            
            generator.appliesPreferredTrackTransform=true;
            generator.maximumSize = maxSize;
            dispatch_async(queue){
                generator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime:thumbTime)]){ (requestedTime, im, actualTime, result, error) in
                    if(result != AVAssetImageGeneratorResult.Succeeded){
                        println("Couldn't generate thumbnail for file: \(file)");
                    } else {
                        self.images.append(UIImage(CGImage: im));
                        
                    }
                }
            }
            fileURLs.append(fileURL);
        }
        
        dispatch_async(queue){
            dispatch_sync(dispatch_get_main_queue()){
                self.collectionView!.reloadData();
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as UICollectionViewCellStyleImage;
        
        cell.imageView.image = images[indexPath.item];
        return cell;
    }
    
    @IBAction func cancelPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
}
