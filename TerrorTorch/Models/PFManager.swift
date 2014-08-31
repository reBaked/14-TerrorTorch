//
//  MoodManager.swift
//  LocoChat
//
//  Created by Alfred Cepeda on 8/9/14.
//  Copyright (c) 2014 Alfred Cepeda. All rights reserved.
//

import Foundation



struct User{
    private static var _user:PFUser!
    private static var _userID:String!
    private static let queue = dispatch_queue_create("com.reBaked.Parse", nil);
    static let FBReadPermissions = ["public_profile", "user_friends"];
    static let FBPublishPermissions = ["publish_actions"];
    static var FBDefaultPermissions:[String]{
        return FBReadPermissions + FBPublishPermissions;
    }
    
    static var isLoggedIn:Bool{
        get{
            return (_user != nil)
        }
    }
    
    static var isFacebookUser:Bool{
        get{
            return PFFacebookUtils.isLinkedWithUser(_user);
        }
    }
    
    static func loginLink_facebook(completionHandler:(Bool) -> ()){
        if(_user == nil){
            println("Will attempt to login to facebook with default permissions");
            PFFacebookUtils.logInWithPermissions(FBDefaultPermissions){ (newUser, error) in
                if(newUser != nil){
                    println("User successfully logged into facebook");
                    self._user = newUser;
                    self._userID = newUser.objectId;
                } else {
                    (error == nil) ? println("User cancelled login") : println("FBLogin request failed with error: \(error)");
                }
                completionHandler(self.isFacebookUser);
            }
        } else if(!PFFacebookUtils.isLinkedWithUser(_user)){
            println("Will attempt to link to facebook with default permissions");
            PFFacebookUtils.linkUser(_user, permissions: FBDefaultPermissions){ (success, error) in
                if(success){
                    println("User successfully linked to facebook");
                } else {
                    (error == nil) ? println("User did not link account") : println("FBLink request failed with error: \(error)");
                }
                completionHandler(self.isFacebookUser);
            }
        }
    }
    
    static func postToFacebook(message: String!){
        
    }
}