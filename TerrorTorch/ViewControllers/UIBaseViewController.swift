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
        
        self.navigationItem.title = self.title;
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "shopbtn"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("presentShopScene"));
    }
    
    func presentShopScene(){
        let storyboard = UIStoryboard(name:"Main", bundle: nil);
        let shopVC = storyboard.instantiateViewControllerWithIdentifier("ShopScene") as UIViewController;
        self.navigationController.pushViewController(shopVC, animated: true);
    }
    
}