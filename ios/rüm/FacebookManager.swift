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

    var username:String?
    var first_name:String? {
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "FIRST_NAME")
        } get {
            return NSUserDefaults.standardUserDefaults().valueForKey("FIRST_NAME") as? String
        }
    }
    var last_name:String?
    var photo:UIImage? {
        set {
            if newValue != nil {
                NSUserDefaults.standardUserDefaults().setObject(UIImagePNGRepresentation(newValue!), forKey: "PROFILE_IMAGE")
            }
        } get {
            let imageData = NSUserDefaults.standardUserDefaults().objectForKey("PROFILE_IMAGE") as! NSData
            return UIImage(data: imageData)
        }
    }
    var imageURL:String?
    
    func login(viewController:UIViewController) {
        FBSDKLoginManager().logInWithReadPermissions(["public_profile"], fromViewController: viewController, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) in
            if (error != nil) {
                FBSDKLoginManager().logOut()
                print("error: ", error)
            } else if (result.isCancelled) {
                FBSDKLoginManager().logOut()
                print ("cancelled")
            } else {
                self.loadFBDetails(viewController)
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
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.width(500)"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    if let name = result["name"] as? String {
                        self.username = name
                    }
                    
                    if let first_name = result["first_name"] as? String {
                        self.first_name = first_name
                    }
                    
                    if let last_name = result["last_name"] as? String {
                        self.last_name = last_name
                    }
                    
                    
                    if let id = result["id"] as? String {
                        NSUserDefaults.standardUserDefaults().setValue(id, forKey: "ID")
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
                            self.imageURL = url
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