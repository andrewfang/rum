//
//  JoinViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/3/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
        
        // NetworkManager will send out notifications if the user join was successful
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoinViewController.userJoined(_:)), name: NetworkingManager.Constants.USER_JOINED_GROUP, object: nil)
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
        
        textField.attributedPlaceholder = NSAttributedString(string: "code", attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
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
        NetworkingManager.sharedInstance.joinUserToGroup(id, groupId: text)
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
            
            if (response.statusCode == 200) {
                NSUserDefaults.standardUserDefaults().setValue(self.textField.text!, forKey: MainViewController.Constants.GROUP_ID)
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print(response)
                let notif = UIAlertController(title: "Error", message: "No group exists with code \"\(self.textField.text!)\". Please double check your code and try again.", preferredStyle: .Alert)
                notif.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                
                self.presentViewController(notif, animated: true, completion: nil)
            }
        })
    }

}
