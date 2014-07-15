//
//  UICircularGestureRecognizer.swift
//  TerrorTorch
//
//  Created by Michael Honaker on 7/10/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import Foundation
import UIKit

class UICircularGestureRecognizer: UIGestureRecognizer {
    
    /**
    *   Tracks current rotation value
    */
    var rotation:Float = 0.0;
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        if event.touchesForGestureRecognizer(self).count > 1 {
            self.state = .Failed;
        }
    }
    
    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        if UIGestureRecognizerState.Changed == self.state {
            self.state = .Ended;
        } else {  
            self.state = .Failed;
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        self.state = UIGestureRecognizerState.Failed;
    }
    
    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!)  {
        if .Possible == self.state {
            self.state = .Began;
        } else {
            self.state = .Changed;
        }
        
        let touch = touches.anyObject() as UITouch;
        let view = self.view;
        let center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)); // rotation around center axis
        let current = touch.locationInView(view);
        let previous = touch.previousLocationInView(view);
        let radians:Float = atan2f(Float(current.y - center.y), Float(current.x - center.x)) - atan2f(Float(previous.y - center.y), Float(previous.x - center.x));
        self.rotation = radians;
    }
    
    //==========================================================================
    // CLASS METHODS
    //==========================================================================
    
    /**
    *   Rotates the view attached to the gesture recognizer based on the recognizers current rotation
    *   @param circularRecognizer:UICircularGestureRecognizer
    */
    class func rotateView(circularRecognizer: UICircularGestureRecognizer!) {
        let view:UIView = circularRecognizer.view;
        view.transform = CGAffineTransformRotate(view.transform, CGFloat(circularRecognizer.rotation));
    }
    
    /**
    *   Rotates the passed view to the specified degree (degree is relative to view's current rotation)
    *   @param view:UIView
    *   @param degrees:Float A degree value between -180.0 and 180.0
    */
    class func rotateView(view: UIView!, degrees: Float) {
        view.transform = CGAffineTransformRotate(view.transform, CGFloat(UICircularGestureRecognizer.degreesToRadians(degrees)));
    }
    
    /**
    *   Converts between degrees and radians
    *   @param degrees:Float
    *   @return Float
    */
    class func degreesToRadians(degrees: Float) -> Float {
        return (Float(M_PI) * degrees / 180.0);
    }
    
    /**
    *   Converts between radians and degrees
    *   @param radians:Float
    *   @return Float
    */
    class func radiansToDegrees(radians: Float) -> Float {
        return (radians * 180.0 / Float(M_PI));
    }
}
