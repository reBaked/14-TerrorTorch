//
//  UIBaseViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/24/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

class UIBaseViewController:UIViewController {

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        //Set navigation title to title specified in IB
        if let title = self.getTitle(){                     //Try to get the Red/White attributed text if able
            self.navigationItem.titleView = title;
        } else {                                            //Otherwise just set the current title to default App appearance
            self.navigationItem.title = self.title;
        }
        
        //Add back button to navigation bar unless already at main menu scene
        if(self.title != "Main Menu"){
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logo").imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("popCurrentController"));
            
        }
        
        if(self.title != "Video Upload" && self.title != "About") {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "shopbtn").imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("pushVideoUploadController"));
        }

        if(self.title == "About") {
            self.navigationItem.rightBarButtonItem?.image = UIImage(named: "shopbtn").imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        }

    }
    
    //Returns Red/White attributed text of specified scenes
    func getTitle() -> UILabel?{
        let label = UILabel(frame: CGRectMake(0, 0, 200, 100));
        label.textAlignment = NSTextAlignment.Center;
        
        if(self.title == "Main Menu"){
            label.attributedText = NSAttributedString(attributedString: self.getNavTitle("Terror", second: "Gallery"));
        } else if(self.title == "Terror Mode"){
            label.attributedText = NSAttributedString(attributedString: self.getNavTitle("Terror", second: "Mode"));
        } else if(self.title == "Sound Box"){
            label.attributedText = NSAttributedString(attributedString: self.getNavTitle("Sound", second: "Box"));
        } else if(self.title == "Video Upload"){
            label.attributedText = NSAttributedString(attributedString: self.getNavTitle("Video", second: "Upload"));
        } else {
            return nil;
        }
        
        return label;
    }
    
    //Returns a Red/White attributed text of provided strings
    func getNavTitle(first:String, second:String) -> NSAttributedString{
        var result = NSMutableAttributedString(string: first, attributes: [NSForegroundColorAttributeName:COLOR_RED]);
        result.appendAttributedString(NSAttributedString(string: second, attributes: [NSForegroundColorAttributeName:COLOR_WHITE]));
        return NSAttributedString(attributedString: result);
    }
    
    func pushVideoUploadController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let vc = storyboard.instantiateViewControllerWithIdentifier("videoUpload") as VideoUploadViewController;
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    //Called when back button on navigation bar is pressed
    func popCurrentController(){
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    
}