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
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("userDoubleTapped:"));
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRecognizer);
        
        self.player.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.New, context: nil);
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func userDoubleTapped(recognier:UITapGestureRecognizer){
        self.player.removeObserver(self, forKeyPath: "status");
        self.navigationController.popViewControllerAnimated(true);
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
