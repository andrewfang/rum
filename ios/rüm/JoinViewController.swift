//
//  JoinViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/3/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController, EnableNotifsViewControllerDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        self.setupTextField()
        
        // NetworkManager will send out notifications if the user join was successful
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoinViewController.userJoined(_:)), name: NetworkingManager.Constants.USER_JOINED_GROUP, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoinViewController.groupDontExist(_:)), name: NetworkingManager.Constants.GROUP_DOESNT_EXIST, object: nil)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.becomeFirstResponder()
    }
    
    // Textfield is just a line, white text and light gray hint text
    private func setupTextField() {
        self.textField.tintColor = UIColor.whiteColor()
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    @IBAction func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func join() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        guard let text = self.textField.text where text.characters.count > 0 else {
            return
        }
        
        guard let id = userDefaults.stringForKey("ID") else {
            return
        }
        
        // If it hits here, we're ready to try joining the group
        self.activityIndicator.startAnimating()
        
        let eventLabel = "\(NSUserDefaults.standardUserDefaults().stringForKey("ID")) : \(text)"
        GA.sendEvent("group", action: "join", label: eventLabel, value: nil)
        
        NetworkingManager.sharedInstance.joinUserToGroup(id, groupCode: text)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Actions triggered by NetworkManager
    func userJoined(notification: NSNotification) {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.activityIndicator.stopAnimating()
            
            guard let userInfo = notification.userInfo else {
                return
            }
            
            guard let response = userInfo["response"] as? NSHTTPURLResponse else {
                return
            }
            
            if (response.statusCode == 200 || response.statusCode == 409) {
                if let tabvc = self.presentingViewController as? UITabBarController {
                    if let navvc = tabvc.viewControllers![1] as? UINavigationController {
                        if let mainvc = navvc.viewControllers.first as? MainViewController {
                            mainvc.setupTasks()
                        }
                    }
                }
                if (NotificationManager.sharedInstance.notificationsAllowed()) {
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.performSegueWithIdentifier(EnableNotifsViewController.Constants.SETUP_NOTIF_SEGUE, sender: nil)
                }
                
            } else if (response.statusCode == 404){
                let notif = UIAlertController(title: "Error", message: "No group exists with code \"\(self.textField.text!)\". Please double check your code and try again.", preferredStyle: .Alert)
                notif.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                
                self.presentViewController(notif, animated: true, completion: nil)
            } else {
                let notif = UIAlertController(title: "Error: \(response.statusCode)", message: "Check your network connection and try again.", preferredStyle: .Alert)
                notif.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                
                self.presentViewController(notif, animated: true, completion: nil)
            }
        })
    }
    
    func groupDontExist(notification:NSNotification) {
        
        var message = "Not sure what happened"
        
        if let userInfo = notification.userInfo {
            if let statusCode = userInfo["status"] as? Int {
                switch (statusCode) {
                case 404:
                    message = "No group exists with code \"\(self.textField.text!)\". Please double check your code and try again."
                case 409:
                    message = ""
                default:
                    message = "Error: status code \(statusCode)"
                }
                
            }
        }
        
        
        
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.activityIndicator.stopAnimating()
            
            if (message == "") {
                // Error 409, user already part of group. Just take them there.
                if (NotificationManager.sharedInstance.notificationsAllowed()) {
                    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                } else {
                    self.performSegueWithIdentifier(EnableNotifsViewController.Constants.SETUP_NOTIF_SEGUE, sender: nil)
                }
            } else {
                let notif = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                notif.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                
                self.presentViewController(notif, animated: true, completion: nil)
            }
        })
        
    }
    
    // MARK: - Enable push notifs vc delegate
    func userDidMakeSelection() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == EnableNotifsViewController.Constants.SETUP_NOTIF_SEGUE {
            if let nav = segue.destinationViewController as? UINavigationController {
                if let vc = nav.childViewControllers.first as? EnableNotifsViewController {
                    vc.delegate = self
                }
            }
        }
    }
}
