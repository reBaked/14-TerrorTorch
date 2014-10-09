//
//  VideoUploadViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 9/7/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import CoreMedia
import Social

class VideoUploadViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var fileURLs:[NSURL] = []
    var images:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let fileManager = NSFileManager();
        let paths = fileManager.contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);
        let tmpDirectory = NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);
        
        let queue = dispatch_queue_create("com.reBaked.ImageGenerator", nil);
        for file in tmpDirectory as [String]{
            if(file.pathExtension == "mov"){
                let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + file)
                let asset = AVURLAsset(URL: fileURL, options: nil);
                let generator = AVAssetImageGenerator(asset: asset);
                let thumbTime = CMTimeMakeWithSeconds(4, 30);
                let maxSize = CGSizeMake(320, 180);
            
                println("Generating thumbnail for file: \(file)");
                generator.appliesPreferredTrackTransform=true;
                generator.maximumSize = maxSize;
                dispatch_async(queue){
                    generator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime:thumbTime)]){ (requestedTime, im, actualTime, result, error)  in
                        if(result != AVAssetImageGeneratorResult.Succeeded){
                            println("Couldn't generate thumbnail for file: \(file)");
                        } else {
                            dispatch_sync(dispatch_get_main_queue()){
                                self.images.append(UIImage(CGImage: im));
                                self.collectionView!.reloadData();
                            }
                        }
                    }
                }
                fileURLs.append(fileURL);
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logo").imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("popCurrentController"));
    }
    
    func popCurrentController(){
        self.navigationController!.popViewControllerAnimated(true);
    }   
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as UICollectionViewCellStyleImage
        
        cell.imageView.image = images[indexPath.item]
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let movieURL = fileURLs[indexPath.item]
        let activityItems = [movieURL]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
}
