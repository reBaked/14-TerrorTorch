//
//  SettingsViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 6/30/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet strong var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let htmlFile = NSBundle.mainBundle().pathForResource("credits", ofType: "html");
        let htmlString = NSString.stringWithContentsOfFile(htmlFile, encoding: NSUTF8StringEncoding, error: nil);
        webView.loadHTMLString(htmlString, baseURL: nil);
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("dismissController:"));
        swipeRecognizer.direction = UISwipeGestureRecognizerDirection.Right;
        self.view.addGestureRecognizer(swipeRecognizer);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController.navigationBar.hidden = false;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissController(recognizer: UISwipeGestureRecognizer){
        println("there")
        if(recognizer.state == UIGestureRecognizerState.Ended){
            println("here");
            self.navigationController.popViewControllerAnimated(true);
            //self.dismissViewControllerAnimated(false, completion: nil);
        }
    }
}
