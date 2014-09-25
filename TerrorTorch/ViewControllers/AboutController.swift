//
//  AboutController.swift
//  TerrorTorch
//
//  Created by Eric Walker on 9/24/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import UIKit

class AboutController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // self.view.setTranslatesAutoresizingMaskIntoConstraints(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func dismiss(sender: UITapGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended){ //Had to cast to raw because equality wasn't working
            dismissViewControllerAnimated(true, completion: { //Dismiss motion detector
            });
        }
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
