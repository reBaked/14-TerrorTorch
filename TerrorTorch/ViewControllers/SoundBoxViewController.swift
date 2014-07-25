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

    var presentedScene:SKScene? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let spriteView = self.view as SKView;
        
        //Diagnostic info
        spriteView.showsDrawCount = true;
        spriteView.showsNodeCount = true;
        spriteView.showsFPS = true;
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //Create scene
        let scene = SoundBoxScene(size: CGSizeMake(768, 1024));
        let spriteView = self.view as SKView;
        
        //Present it
        spriteView.presentScene(scene);
        presentedScene = scene;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
