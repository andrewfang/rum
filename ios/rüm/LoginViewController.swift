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
    }
    
    @IBAction func login() {
        FacebookManager.sharedInstance.login(self)
        self.activityIndicator.startAnimating()
    }
    
    override func notifyLoggedIn() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let deviceToken = userDefaults.stringForKey(NotificationManager.Constants.DEVICE_TOKEN),
            userId = userDefaults.stringForKey("ID") {
             NetworkingManager.sharedInstance.registerUser(userId, deviceToken: deviceToken)
        }
        self.activityIndicator.stopAnimating()
        self.performSegueWithIdentifier(Constants.WELCOME_SEGUE, sender: nil)
        
    }
    
}
