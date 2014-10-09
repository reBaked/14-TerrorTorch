//
//  ViewController.swift
//  TerrorTorch
//
//  Created by ben on 6/17/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

class MainScreenController: UIBaseViewController {
    /**
    *  Called when user swipes to the right
    */    
    @IBAction func presentSettingsScreen(sender: UISwipeGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended){ //Had to cast to raw because equality wasn't working
            self.performSegueWithIdentifier("mainToSettings", sender: self);
        }

    }
}
