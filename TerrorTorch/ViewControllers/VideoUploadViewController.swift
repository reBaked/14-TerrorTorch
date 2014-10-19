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
    
    override func viewWillLayoutSubviews() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logo").imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("popCurrentController"));
    }
    
    func popCurrentController(){
        self.navigationController!.popViewControllerAnimated(true);
    }   
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VideoFileManager.images.count;
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as UICollectionViewCellStyleImage
        
        cell.imageView.image = VideoFileManager.images[indexPath.item]
        return cell
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let movieURL = VideoFileManager.fileURLs[indexPath.item]
        let activityItems = [movieURL]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
}
