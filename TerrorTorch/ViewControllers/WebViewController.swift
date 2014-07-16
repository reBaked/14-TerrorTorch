//
//  WebViewController.swift
//  TerrorTorch
//
//  Created by Dylan Edwards on 7/16/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    // MARK: Properties
    let url: String = "http://www.goldenviking.org/"
    
    @IBOutlet var webView: UIWebView
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWebView()
        loadAddressURL()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // MARK: Convenience
    
    func loadAddressURL() {
        let requestURL = NSURL(string: url)
        let request = NSURLRequest(URL: requestURL)
        webView.loadRequest(request)
    }
    
    // MARK: Configuration
    
    func configureWebView() {
        webView.backgroundColor = UIColor.whiteColor()
        webView.scalesPageToFit = true
        webView.dataDetectorTypes = .All
    }
    
    // MARK: UIWebViewDelegate
    
    func webViewDidStartLoad(_: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        // Report the error inside the web view.
        let localizedErrorMessage = NSLocalizedString("An error occured:", comment: "")
        
        let errorHTML = "<!doctype html><html><body><div style=\"width: 100%%; text-align: center; font-size: 36pt;\">\(localizedErrorMessage) \(error.localizedDescription)</div></body></html>"
        
        webView.loadHTMLString(errorHTML, baseURL: nil)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
