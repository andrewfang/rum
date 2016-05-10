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
    
    @IBOutlet weak var createGroupStackView:UIStackView!
    @IBOutlet weak var showCodeStackView:UIStackView!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - Btn Actions
    @IBAction private func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction private func createGroup() {
        guard let text = self.textField.text where text.characters.count > 0 else {
            return
        }
        
        self.activityIndicator.startAnimating()
        // "userId"
        let eventLabel = "\(NSUserDefaults.standardUserDefaults().stringForKey("ID"))"
        GA.sendEvent("group", action: "create", label: eventLabel, value: nil)
        NetworkingManager.sharedInstance.createGroup(text)
        
    }
    
    // MARK: - View Controller Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
        
        // NetworkManager will send out notifications if the user join was successful
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateGroupViewController.groupCreated(_:)), name: NetworkingManager.Constants.USER_CREATED_GROUP, object: nil)

        self.showCodeStackView.alpha = 0
        self.showCodeStackView.hidden = true
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
    
    func groupCreated(notification: NSNotification) {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.activityIndicator.stopAnimating()
            
            guard let userInfo = notification.userInfo else {
                return
            }
            
            guard let code = userInfo["code"] as? String else {
                return
            }
            
            self.codeLabel.text = code
            
            self.textField.resignFirstResponder()
            
            UIView.animateWithDuration(1.0, animations: {
                self.showCodeStackView.hidden = false
                self.showCodeStackView.alpha = 1.0
                self.createGroupStackView.alpha = 0.0
                self.backButton.hidden = true
                }, completion: { done in
                    self.createGroupStackView.hidden = true
                    
            })
        })
    }
    
    @IBAction private func done() {
        if let tabvc = self.presentingViewController as? UITabBarController {
            if let navvc = tabvc.viewControllers?.first as? UINavigationController {
                if let mainvc = navvc.viewControllers.first as? MainViewController {
                    mainvc.setupTasks()
                }
            }
        }
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
