//
//  ViewController.swift
//  TerrorTorch
//
//  Created by ben on 6/17/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//
import AVKit

class MainScreenController: UIBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var collectionView: UICollectionView!;
    var selectedItem = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.collectionView.backgroundColor = UIColor.clearColor();
        
        VideoFileManager.generateImages(){
            println("Completion called");
            self.collectionView.reloadData();
        }
    }
    
    /**
    *  Called when user swipes to the right
    */    
    @IBAction func presentSettingsScreen(sender: UISwipeGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended){ //Had to cast to raw because equality wasn't working
            self.performSegueWithIdentifier("mainToSettings", sender: self);
        }

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
        self.selectedItem = indexPath.item;
        performSegueWithIdentifier("mainToPlayer", sender: self);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "mainToPlayer"){
            let playerVC = segue.destinationViewController as AVPlayerViewController;
            let avPlayer = AVPlayer(URL: VideoFileManager.fileURLs[selectedItem]);
            playerVC.player = avPlayer;
        }
    }
}
