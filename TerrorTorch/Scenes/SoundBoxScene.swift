//
//  SoundBoxScene.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/3/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import SpriteKit
import AVFoundation
import CoreMedia

class SoundBoxScene: SKScene {
    
    override func didMoveToView(view: SKView!) {
        self.createSceneContents();
    }
    
    func createSceneContents(){
        self.backgroundColor = UIColor.blackColor();
        self.scaleMode = SKSceneScaleMode.AspectFit;
        
        var image = SKSpriteNode(texture: SKTexture(imageNamed: "dollhead.png"), color: UIColor.whiteColor(), size: CGSizeMake(200, 200));
        
        image.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        image.name = "dollhead";
        self.addChild(image);
    }
    
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        let touch : AnyObject! = touches.anyObject();
        let location = touch.locationInNode(self);
        if let node = self.nodeAtPoint(location){
            if let name = node.name{
                if(name == "dollhead"){
                    self.runAction(SKAction.playSoundFileNamed("young-girl-scream.wav", waitForCompletion: false));
                    
                    let path = NSBundle.mainBundle().pathForResource("young-girl-scream", ofType: "wav");
                    let url = NSURL.fileURLWithPath(path);
                    let audioAsset = AVURLAsset.URLAssetWithURL(url, options: nil);
                    let duration = audioAsset.duration;
                    node.runAction(SKAction.rotateByAngle(CGFloat(6*M_PI), duration: CMTimeGetSeconds(duration)));
                }
            }
        }
    }
}
