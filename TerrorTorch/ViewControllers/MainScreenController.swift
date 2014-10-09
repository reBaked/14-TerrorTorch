//
//  ViewController.swift
//  TerrorTorch
//
//  Created by ben on 6/17/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

class MainScreenController: UIBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var viewYoutubeVideos: UICollectionView!
    @IBOutlet var btnFacebook: UIButton!
    @IBOutlet var btnTwitter: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        YoutubeManager.getVideoSnippets(20){ (videoIDs, imageURLs) in
            if(!videoIDs.isEmpty){
                YoutubeManager.fetchImagesFromURLs(){ (images) in
                    if(!images.isEmpty){
                        self.viewYoutubeVideos.reloadData();
                    }
                }
            }
        }
        
        if(User.isLoggedIn){
            if(User.isFacebookUser){
                btnFacebook.enabled = false;
                btnFacebook.hidden = true;
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {

    }
    
    /**
    *  Called when user swipes to the right
    */    
    @IBAction func presentSettingsScreen(sender: UISwipeGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended){ //Had to cast to raw because equality wasn't working
            self.performSegueWithIdentifier("mainToSettings", sender: self);
        }

    }
    
    @IBAction func socialBtnTouchUpInside(sender: UIButton) {
        if(sender == btnFacebook){
            self.btnFacebook.enabled = false;
            User.loginLinkFacebook(){
                if($0){
                    self.btnFacebook.hidden = true;
                } else {
                    self.btnFacebook.enabled = true;
                }
            }
        } else if(sender == btnTwitter){
            
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let videoIDs = YoutubeManager.videoIDs{
            return videoIDs.count
        } else {
            return 0;
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("youtubeCell", forIndexPath: indexPath) as UICollectionViewCellStyleImage;

        cell.imageView.image = YoutubeManager.images![indexPath.item];
        return cell;
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        YoutubeManager.playVideoAtIndexPath(indexPath, presentingViewController: self);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width = collectionView.bounds.width/4;
        width = width + (width * 1/4);
        return CGSizeMake(width, width);
    }
    
}
