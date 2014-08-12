//
//  Global Context.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 8/5/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

// MARK: Global Constants

// Format for sound files
let SOUNDFORMAT:String = "wav";

// Color Constants in HEX
let COLOR_RED:UIColor = UIColor(hexColor:0xC11D25);
let COLOR_BLACK:UIColor = UIColor(hexColor:0x040404);
let COLOR_WHITE:UIColor = UIColor(hexColor:0xFFFAFA);
let COLOR_GREY:UIColor = UIColor(hexColor:0x2C2E2D);

// Logo Constants
let FONT_TITLE:UIFont = UIFont(name: "HelveticaNeue", size: 20.0);

//An array of dictionaries containing information about the assets used in SoundBox and TerrorMode
let appAssets = [
    ["name":"Dollhead",     "imageName":"dollhead",     "soundName":"young-girl-scream"],
    ["name":"Knife",        "imageName":"knife",        "soundName":"knife-stab-splatter"],
    ["name":"Pitchfork",    "imageName":"pitchfork",    "soundName":"devil-laugh"],
    ["name":"Anubis",       "imageName":"Anubis",       "soundName":"ghost-egyptian-phantom"]
];

// MARK: Global Functions
func initStyles() {
    UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false);
    let navBar = UINavigationBar.appearance();
    let regBtn = UIButton.appearance();
    let barBtn = UIBarButtonItem.appearance();
    
    navBar.titleTextAttributes = [ NSFontAttributeName: FONT_TITLE, NSForegroundColorAttributeName: COLOR_RED ];
    navBar.setBackgroundImage(UIImage(named: "bar-bg"), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default);
    navBar.tintColor = COLOR_RED;
    regBtn.tintColor = COLOR_RED;
    barBtn.tintColor = COLOR_RED;
}

// Dollar Swift's function for finding matches in an array
func find<T: Equatable>(array: [T], iterator: (T) -> Bool) -> T? {
    for elem in array {
        let result = iterator(elem)
        if result {
            return elem
        }
    }
    return nil
}