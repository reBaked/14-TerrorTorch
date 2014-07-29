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
            label.attributedText = NSAttributedString(attributedString: self.getNavTitle("Main", second: "Menu"));
        } else if(self.title == "Terror Mode"){
            label.attributedText = NSAttributedString(attributedString: self.getNavTitle("Terror", second: "Mode"));
        } else if(self.title == "Sound Box"){
            label.attributedText = NSAttributedString(attributedString: self.getNavTitle("Sound", second: "Box"));
        } else {
            return nil;
        }
        
        return label;
    }
    
    func getNavTitle(first:String, second:String) -> NSAttributedString{
        var result = NSMutableAttributedString(string: first, attributes: [NSForegroundColorAttributeName:COLOR_RED]);
        result.appendAttributedString(NSAttributedString(string: second, attributes: [NSForegroundColorAttributeName:COLOR_WHITE]));
        return NSAttributedString(attributedString: result);
    }
    
    func popCurrentController(){
        self.navigationController.popViewControllerAnimated(true);
    }
    
    
}