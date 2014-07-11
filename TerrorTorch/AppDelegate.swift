//
//  AppDelegate.swift
//  TerrorTorch
//
//  Created by ben on 6/17/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit

/**
*  Appwide constants here:
*/

// SoundBox Sound Format
let SOUNDFORMAT:String = ".wav";

// Color Constants in HEX
let COLOR_RED:UIColor = UIColor(hexColor:0xC11D25);
let COLOR_BLACK:UIColor = UIColor(hexColor:0x040404);
let COLOR_WHITE:UIColor = UIColor(hexColor:0xFFFAFA);
let COLOR_GREY:UIColor = UIColor(hexColor:0x2C2E2D);

// Logo Constants
let FONT_TITLE:UIFont = UIFont(name: "HelveticaNeue", size: 20.0);

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        initStyles();
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func initStyles() {
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false);
        let navBar:UINavigationBar = UINavigationBar.appearance();
        let regBtn:UIButton = UIButton.appearance();
        let barBtn:UIBarButtonItem = UIBarButtonItem.appearance();
        
        navBar.titleTextAttributes = [ NSFontAttributeName: FONT_TITLE, NSForegroundColorAttributeName: COLOR_WHITE ];
        navBar.setBackgroundImage(UIImage(named: "bar-bg"), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default);
        navBar.tintColor = COLOR_RED;
        regBtn.tintColor = COLOR_RED;
        barBtn.tintColor = COLOR_RED;
    }
}

