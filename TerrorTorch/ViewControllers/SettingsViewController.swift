//
//  SettingsViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 6/30/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("dismissThisController:"));
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right;
        self.view.addGestureRecognizer(swipeRecognizer);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissThisController(recognizer: UISwipeGestureRecognizer){
        if(recognizer.state == UIGestureRecognizerState.Ended){
            self.dismissViewControllerAnimated(true, completion: nil);
        }
    }
}
