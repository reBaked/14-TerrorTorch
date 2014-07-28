//
//  SoundBoxViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 6/30/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit
import AVFoundation
import SpriteKit

class SoundBoxViewController: UIBaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let spriteView = self.view as SKView;
        
        //Diagnostic info
        spriteView.showsDrawCount = true;
        spriteView.showsNodeCount = true;
        spriteView.showsFPS = true;
        
        //Create scene
        let scene = SoundBoxScene(size: self.view.frame.size);
        
        //Present it
        spriteView.presentScene(scene);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
