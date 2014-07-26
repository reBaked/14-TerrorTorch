//
//  UIBaseViewController.swift
//  TerrorTorch
//
//  Created by Alfred Cepeda on 7/24/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//

import Foundation

class UIBaseViewController : UIViewController{

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();

        if let title = self.getTitle(){
            self.navigationItem.titleView = title;
        } else {
            self.navigationItem.title = self.title;
        }

        if(self.title != "Shop"){
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "shopbtn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("presentShopScene"));
        }
        if(self.title != "Main Menu")
        {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logo"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("popCurrentController"));
        }
    }
    
    func presentShopScene(){
        let storyboard = UIStoryboard(name:"Main", bundle: nil);
        let shopVC = storyboard.instantiateViewControllerWithIdentifier("ShopScene") as UIViewController;
        self.navigationController.pushViewController(shopVC, animated: true);
    }
    
    
    func getTitle() -> UILabel?{
        let label = UILabel(frame: CGRectMake(0, 0, 200, 100));
        label.textAlignment = NSTextAlignment.Center;
        
        if(self.title == "Main Menu"){
            let result = NSMutableAttributedString(string: "Main", attributes: [NSForegroundColorAttributeName:COLOR_RED]);
            result.appendAttributedString(NSAttributedString(string: "Menu", attributes: [NSForegroundColorAttributeName:COLOR_WHITE]));
            label.attributedText = NSAttributedString(attributedString: result);
        } else if(self.title == "Terror Mode"){
            let result = NSMutableAttributedString(string: "Terror", attributes: [NSForegroundColorAttributeName:COLOR_RED]);
            result.appendAttributedString(NSAttributedString(string: "Mode", attributes: [NSForegroundColorAttributeName:COLOR_WHITE]));
            label.attributedText = NSAttributedString(attributedString: result);
        } else if(self.title == "Sound Box"){
            let result = NSMutableAttributedString(string: "Sound", attributes: [NSForegroundColorAttributeName:COLOR_RED]);
            result.appendAttributedString(NSAttributedString(string: "Box", attributes: [NSForegroundColorAttributeName:COLOR_WHITE]));
            label.attributedText = NSAttributedString(attributedString: result);
        } else {
            return nil;
        }
        
        return label;
    }
    
    func popCurrentController(){
        self.navigationController.popViewControllerAnimated(true);
    }
    
    
}