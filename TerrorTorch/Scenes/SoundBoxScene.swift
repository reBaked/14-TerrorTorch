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

enum SpriteAttribute:String{
    case Name = "name"
    case SoundName = "soundname"
    case SoundPath = "soundpath"
    case Rotations = "rotations" //This needs to be changed to "Animation" with a value that accepts a closure
    case Duration = "duration"
}

class SoundBoxScene: SKScene {
    
    //Information on actions expected by a SKNode
    var actionAttributes:[[String:AnyObject]] = [];
    
    let spriteAssets = ["dollhead", "young-girl-scream",
                        "knife", "knife-stab-splatter",
                        "pitchfork", "devil-laugh",
                        "Anubis", "ghost-egyptian-phantom"];
    
    override func didMoveToView(view: SKView!) {
        self.configureScene();
        self.createSceneContents();
    
        //Initialize gesture recognizers
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"));
        self.view.addGestureRecognizer(singleTapRecognizer);

    }
    
    /**
    *  Initial scene configurations
    */
    func configureScene(){
        self.backgroundColor = UIColor.clearColor();
        self.scaleMode = SKSceneScaleMode.AspectFit;

        let background = SKSpriteNode(texture: SKTexture(imageNamed: "woodbgrnd"), size: self.frame.size);
        background.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        self.addChild(background);
    }
    
    /**
    *   Creates nodes to be used in scene.
    *   Everything is hard coded at the moment, this needs to change to something better.
    */
    func createSceneContents(){
        //Create Scene sprites
        var i = 0;
        while(i < spriteAssets.count){
            let name = spriteAssets[i++];
            let soundName = spriteAssets[i++];
    
            var rotations = 0.0;
            var duration = 0.0;
            
            if(name == "dollhead" || name == "anubis"){
                rotations = 6.0
                duration = 3.0;
            }
            
        
            let sprite = createSprite(name, imageName: name);
            let attributes = createSpriteActionAttributes(name, soundName: soundName, rotations: rotations, duration: duration);
            
            self.addChild(sprite);
            actionAttributes.append(attributes);
            
            let quarterWidth = self.frame.width/4;
            let quarterHeight = self.frame.height/4;
            var moveBy:CGPoint;
            switch(i){
                case 2:
                    moveBy = CGPointMake(-quarterWidth, quarterHeight);
                    break;
                case 4:
                    moveBy = CGPointMake(quarterWidth, quarterHeight);
                    break;
                case 6:
                    moveBy = CGPointMake(-quarterWidth, -quarterHeight);
                    break;
                case 8:
                    moveBy = CGPointMake(quarterWidth, -quarterHeight);
                    break;
                default:
                    moveBy = CGPointMake(0,0);
                    break;
            }
            
            moveNode(name, point: moveBy, duration: 3.0);
        }
    }
    
    /**
    *  Create sprite for scene
    *
    *  @param name:String      Name of the sprite, needs to be unique
    *  @param imageName:String Name of image to use for sprite
    *  @param size:CGSize      Size of the sprite
    *
    *  @return Sprite object
    */
    func createSprite(name:String, imageName:String) -> SKSpriteNode{
        
        let sprite = SKSpriteNode(imageNamed: imageName);
        sprite.name = name;
        sprite.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        return sprite;
    }
    
    /**
    *  Positions sprite at node
    *
    *  @param name:String       Name of sprite
    *  @param point:CGPoint     Final position of sprite
    *  @param duration:Double   Animates to final position over duration. 0 will not animate.
    */
    
    func moveNode(name:String, point:CGPoint, duration:Double){
        
        if let node = self.childNodeWithName(name) as? SKSpriteNode{
            //let action = SKAction.moveTo(point, duration: duration);
            let action = SKAction.moveByX(point.x, y: point.y, duration: duration);
            node.runAction(action);
        } else {
            println("Could not find sprite with the name \(name)");
        }
    }
    
    /**
    *  Attributes to be used when generating action for Sprites
    *
    *  @param spriteName:String Name of the sprite, needs to be unique
    *  @param soundName:String  Name of the sound played during animation
    *  @param rotations:Int     Number of times sprite rotates during animation
    *  @param duration:Double   Duration of animation
    *
    *  @return A dictionary storing key value pairs
    */
    func createSpriteActionAttributes(spriteName:String, soundName:String, rotations:Double, duration:Double) -> [String:AnyObject]{
        var result = [String:AnyObject]();
        let path = NSBundle.mainBundle().pathForResource(soundName, ofType: SOUNDFORMAT);
        result.updateValue(spriteName, forKey: SpriteAttribute.Name.toRaw());
        result.updateValue(soundName, forKey: SpriteAttribute.SoundName.toRaw());
        result.updateValue(path, forKey: SpriteAttribute.SoundPath.toRaw());
        result.updateValue(rotations, forKey: SpriteAttribute.Rotations.toRaw());
        result.updateValue(duration, forKey: SpriteAttribute.Duration.toRaw())
        
        return result;
    }
    
    /**
    *  Evaluates any node that's present in scene based on its type and returns a default set of actions for that type based on stored attributes
    *
    *  @param node:SKNode Node to evalute, must have information available in childrenAttributes
    *
    *  @return Default actions for node. Will be node if no attributes have been defined
    */
    func evaluateNode(node:SKNode) -> [SKAction]?{
        //Get attribute information for node
        if let attributes = getAttributesForNode(node){
            
            //Attempt to cast as Sprite
            if let sprite = node as? SKSpriteNode{
                //Cast sprite attributes
                let soundFilename = (attributes[SpriteAttribute.SoundName.toRaw()]! as String) + SOUNDFORMAT;
                let rotations = (attributes[SpriteAttribute.Rotations.toRaw()]! as Double);
                let duration = (attributes[SpriteAttribute.Duration.toRaw()]! as Double);
                
                //Create sprite actions
                let soundAction = SKAction.playSoundFileNamed(soundFilename, waitForCompletion: false);
                let rotationAction = SKAction.rotateByAngle(CGFloat(rotations*M_PI), duration: NSTimeInterval.abs(duration));
                
                return [soundAction, rotationAction];
            }
            
        } else {
            println("Unable to find attribute information for node: (\(node.name))");
            return nil;
        }
        return nil;
    }
    
    /**
    *  Retrieves stored attribute information for a given node using the node's name.
    *
    *  @param node:SKNode Must have a unique name that is stored within the attributes dictionary
    *
    *  @return Attribute information belonging to node.
    */
    func getAttributesForNode(node:SKNode) -> [String:AnyObject]?{
        if let nodeName = node.name{
            let attributes = $.find(actionAttributes, iterator: {
                if let attributeName = ($0 as [String:AnyObject])["name"]! as? String{
                    return attributeName == nodeName;
                }
                return false;
            })
            
            if let result = attributes as? [String:AnyObject]{
                return result;
            } else {
                println("Couldn't find a action attributes for node named \(nodeName)");
                return nil;
            }
        } else {
            println("Node must have a name in order to find action attributes");
            return nil;
        }
    }
    
    func performActions(actions:[SKAction], onNode node:SKSpriteNode){
        for action in actions{
            node.runAction(action);
        }
    }
    
    /**
    *  Handle user tap gestures
    */
    
    func handleSingleTap(recognizer:UITapGestureRecognizer){
        if(recognizer.state == UIGestureRecognizerState.Ended){
            //Get location in scene and convert point, then get node
            let location = self.convertPointFromView(recognizer.locationInView(recognizer.view));
            if let node = self.nodeAtPoint(location) as? SKSpriteNode{
                //Retrieve actions for that node
                if let actions = evaluateNode(node){
                    self.performActions(actions, onNode: node);
                }else{
                    println("Could not evaluate node: (\(node.name))");
                }
            }
        }
    }
}
