//
//  TempDirBrowseViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/16/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

class TempDirBrowseViewController: UITableViewController {

    var fileNames:[String] = []
    var videoAssets:[AVAsset] = []
    let player = AVPlayer();
    var videoView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let fileManager = NSFileManager();
        let paths = fileManager.contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);
        
        
        let tmpDirectory = NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil);
        
        for file in tmpDirectory as [String]{
            let url = NSURL(fileURLWithPath: NSTemporaryDirectory() + file)
            let item = AVAsset.assetWithURL(url) as AVAsset;

            videoAssets.append(item);
            fileNames.append(url.lastPathComponent);
        }
        /*
        for path in paths as [String]{
            let url = NSURL(fileURLWithPath: path);
            
        }*/

        self.videoView = UIView(frame: self.view.frame);
        self.videoView.hidden = true;
        self.videoView.backgroundColor = UIColor.blackColor();
        
        let playerLayer = AVPlayerLayer(player: player);
        playerLayer.frame = self.view.frame;
        self.videoView.layer.addSublayer(playerLayer);
        
        self.view.addSubview(videoView);
        self.tableView.reloadData();
        
        self.player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil);
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    deinit{
        self.player.removeObserver(self, forKeyPath: "status");
        NSNotificationCenter.defaultCenter().removeObserver(self);
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // #pragma mark - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return (fileNames.isEmpty) ? 0 : 1;
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return fileNames.count;
    }

    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell? {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("MyCell") as? UITableViewCell;
        
        if(!cell){
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MyCell");
        }
        
        cell!.textLabel.text = fileNames[indexPath.row];
        // Configure the cell...

        return cell;
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let item = AVPlayerItem(asset: videoAssets[indexPath.row]);
        
        self.player.replaceCurrentItemWithPlayerItem(item);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("itemDidFinishPlaying:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: item);
        self.player.seekToTime(kCMTimeZero);
        self.videoView.hidden = false;
        self.player.play();
    }
    
    func itemDidFinishPlaying(notification:NSNotification){
        self.videoView.hidden = true;
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafePointer<()>) {
        
        if(player.status == AVPlayerStatus.Failed){
            let error = player.error;
            println(error);
            return;
        }
        
        //super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context);
    }
}
