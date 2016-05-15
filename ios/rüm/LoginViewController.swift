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
    
    var ranLogoAnimation = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
    private struct Constants {
        static let GROUP_SEGUE = "GROUP_SEGUE"
        static let SIGNUP_SEGUE = "SIGNUP_SEGUE"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.checkUser(_:)), name: NetworkingManager.Constants.CHECK_USER_EXISTS, object: nil)
        self.activityIndicator.stopAnimating()
        
        if !self.ranLogoAnimation {
            var t = CGAffineTransformIdentity
            t = CGAffineTransformScale(t, 0.4, 0.4)
            t = CGAffineTransformTranslate(t, 0, 100.0)
            
            logoImageView.transform = t
            logoImageView.alpha = 0
            
            loginButton.transform = CGAffineTransformMakeTranslation(0.0, 40.0)
            loginButton.alpha = 0
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.ranLogoAnimation {
            self.ranLogoAnimation = true
            
            UIView.animateWithDuration(0.6,
                delay: 0.4,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.2,
                options: [],
                animations: {
                    self.loginButton.transform = CGAffineTransformIdentity
                    self.loginButton.alpha = 1
                }, completion: nil)
        
            UIView.animateWithDuration(0.6,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.4,
                options: [],
                animations: {
                    self.logoImageView.transform = CGAffineTransformIdentity
                    self.logoImageView.alpha = 1
                }, completion: nil)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func login() {
        FacebookManager.sharedInstance.login(self)
        self.activityIndicator.startAnimating()
    }
    
    override func notifyLoggedIn() {
        NetworkingManager.sharedInstance.checkUser(NSUserDefaults.standardUserDefaults().stringForKey("ID")!)
    }
    
    override func notifyNotLoggedIn() {
        self.activityIndicator.stopAnimating()
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
            
            if let userId = userDefaults.stringForKey("ID"),
                first_name = FacebookManager.sharedInstance.first_name,
                last_name = FacebookManager.sharedInstance.last_name,
                image_url = FacebookManager.sharedInstance.imageURL
            {
                NetworkingManager.sharedInstance.registerUser(userId, deviceToken: userDefaults.stringForKey(NotificationManager.Constants.DEVICE_TOKEN),
                    firstName: first_name,
                    lastName: last_name,
                    imageUrl: image_url)
            }
            
            if (response.statusCode == 200) {
                // User exists in DB
                self.activityIndicator.stopAnimating()
                
                self.performSegueWithIdentifier(Constants.GROUP_SEGUE, sender: nil)
            } else {
                
                self.activityIndicator.stopAnimating()
                
                self.performSegueWithIdentifier(Constants.SIGNUP_SEGUE, sender: nil)
            }
        })
        
    }
    
}
