//
//  LoginViewController.swift
//  rüm
//
//  Created by Andrew Fang on 4/30/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private struct Constants {
        static let WELCOME_SEGUE = "WELCOME_SEGUE"
        static let SIGNUP_SEGUE = "SIGNUP_SEGUE"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.checkUser(_:)), name: NetworkingManager.Constants.CHECK_USER_EXISTS, object: nil)
    }
    
    @IBAction func login() {
        FacebookManager.sharedInstance.login(self)
        self.activityIndicator.startAnimating()
    }
    
    override func notifyLoggedIn() {
        NetworkingManager.sharedInstance.checkUser(NSUserDefaults.standardUserDefaults().stringForKey("ID")!)
    }
    
    func checkUser(notification:NSNotification) {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.activityIndicator.stopAnimating()
            
            guard let userInfo = notification.userInfo else {
                return
            }
            
            guard let response = userInfo["response"] as? NSHTTPURLResponse else {
                return
            }
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            if (response.statusCode == 200) {
                // User exists in DB
                self.activityIndicator.stopAnimating()
                guard let data = userInfo["data"] as? [String: AnyObject],
                    let groups = data["groups"] as? [AnyObject],
                    let firstGroup = groups[0] as? [String: AnyObject] else {
                        return
                }
                userDefaults.setValue(firstGroup["id"]!, forKey: MainViewController.Constants.GROUP_ID)
                self.performSegueWithIdentifier(Constants.WELCOME_SEGUE, sender: nil)
            } else {
                if let deviceToken = userDefaults.stringForKey(NotificationManager.Constants.DEVICE_TOKEN),
                    userId = userDefaults.stringForKey("ID"),
                    first_name = FacebookManager.sharedInstance.first_name,
                    last_name = FacebookManager.sharedInstance.last_name,
                    image_url = FacebookManager.sharedInstance.imageURL
                {
                    NetworkingManager.sharedInstance.registerUser(userId, deviceToken: deviceToken, firstName: first_name, lastName: last_name, imageUrl: image_url)
                }
                self.activityIndicator.stopAnimating()
                
                self.performSegueWithIdentifier(Constants.SIGNUP_SEGUE, sender: nil)
            }
        })
        
    }
    
}
