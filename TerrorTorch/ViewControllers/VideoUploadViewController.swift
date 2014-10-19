//
//  VideoUploadViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 9/7/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import CoreMedia
import Social

class VideoUploadViewController: UIBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VideoFileManager.images.count;
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("videoCell", forIndexPath: indexPath) as UICollectionViewCellStyleImage
        
        cell.imageView.image = VideoFileManager.images[indexPath.item]
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let movieURL = VideoFileManager.fileURLs[indexPath.item]
        let activityItems = [movieURL]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func cancelPressed(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
}
