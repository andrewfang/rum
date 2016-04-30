//
//  FacebookManager.swift
//  rüm
//
//  Created by Andrew Fang on 4/30/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class FacebookManager {
    
    static let sharedInstance = FacebookManager()
    
    var connected:Bool = NSUserDefaults.standardUserDefaults().boolForKey("LoggedIn")
    var username:String?
    var photo:UIImage?
    
    func login(viewController:UIViewController) {
        FBSDKLoginManager().logInWithReadPermissions(["public_profile"], fromViewController: viewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) in
            if (error != nil) {
                FBSDKLoginManager().logOut()
                print("error: ", error)
            } else if (result.isCancelled) {
                FBSDKLoginManager().logOut()
                print ("cancelled")
            } else {
                print ("connected")
                self.loadFBDetails(viewController)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "LoggedIn")
                self.connected = true
            }
        })
    }
    
    func logout(viewController: UIViewController) {
        if FBSDKAccessToken.currentAccessToken() != nil {
            let disconnectAlert = UIAlertController(title: "Are you sure you want to logout?", message: "", preferredStyle: .Alert)
            disconnectAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            disconnectAlert.addAction(UIAlertAction(title: "Logout", style: .Destructive, handler: {action in
                FBSDKLoginManager().logOut()
            }))
            
            viewController.presentViewController(disconnectAlert, animated: true, completion: nil)
            return
        }
    }
    
    
    private func loadFBDetails(viewController: UIViewController) {
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, picture.width(500)"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    print(result)
                    if let name = result["name"] as? String {
                        self.username = name
                    }
                    
                    guard let picture = result["picture"] as? [String: AnyObject] else {
                        return
                    }
                    guard let data = picture["data"] as? [String: AnyObject] else {
                        return
                    }
                    guard let url = data["url"] as? String else {
                        return
                    }
                    
                    if let nsurl = NSURL(string: url) {
                        if let imageData = NSData(contentsOfURL: nsurl) {
                            self.photo = UIImage(data: imageData)
                        }
                    }
                    viewController.notifyLoggedIn()
                }
            })
        }
    }
}



protocol FBViewController {
    func notifyLoggedIn()
}

extension UIViewController : FBViewController {
    func notifyLoggedIn() {
        return
    }
}