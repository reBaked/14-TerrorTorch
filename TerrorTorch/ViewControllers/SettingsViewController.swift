//
//  SettingsViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 6/30/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

class SettingsViewController: UIViewController {
    @IBOutlet var webView: UIWebView!
    
    override func viewWillLayoutSubviews()  {
        super.viewWillLayoutSubviews()
        // Do any additional setup after loading the view, typically from a nib.
        
        let htmlFile = NSBundle.mainBundle().pathForResource("credits", ofType: "html");
        let htmlString = NSString.stringWithContentsOfFile(htmlFile!, encoding: NSUTF8StringEncoding, error: nil);
        webView.loadHTMLString(htmlString, baseURL: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func presentWebView(sender: UIButton) {
        WebViewController.presentWebViewController("http://www.goldenviking.org/", owner: self);
    }
    @IBAction func dismissController(sender: UISwipeGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended){
            self.dismissViewControllerAnimated(false, completion: nil);
        }
    }
}
