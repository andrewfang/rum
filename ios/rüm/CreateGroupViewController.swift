//
//  CreateGroupViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/3/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var codeLabel:UILabel!
    @IBOutlet weak var textField:UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Btn Actions
    @IBAction private func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction private func createGroup() {
        guard let text = self.textField.text where text.characters.count > 0 else {
            return
        }
        
        guard let id = NSUserDefaults.standardUserDefaults().stringForKey("ID") else {
            return
        }
        
        self.activityIndicator.startAnimating()
        NetworkingManager.sharedInstance.createGroup(id, groupname: text)
        
    }
    
    // MARK: - View Controller Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
        
        // NetworkManager will send out notifications if the user join was successful
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateGroupViewController.userCreated(_:)), name: NetworkingManager.Constants.USER_CREATED_GROUP, object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.becomeFirstResponder()
    }
    
    private func setupTextField() {
        self.textField.tintColor = UIColor.whiteColor()
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.whiteColor().CGColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
        
        textField.attributedPlaceholder = NSAttributedString(string: "group name", attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
    }
    
    func userCreated(notification: NSNotification) {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.activityIndicator.stopAnimating()
            
            guard let userInfo = notification.userInfo else {
                return
            }
            
            guard let response = userInfo["response"] as? NSHTTPURLResponse else {
                return
            }
            
            if (response.statusCode == 200) {
                self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print(response)
                // TODO: fix this
                let notif = UIAlertController(title: "Error", message: "Group name taken: \"\(self.textField.text!)\". Please try another name.", preferredStyle: .Alert)
                notif.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                
                self.presentViewController(notif, animated: true, completion: nil)
            }
        })
    }

}
