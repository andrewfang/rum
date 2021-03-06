//
//  CreateGroupViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/3/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, EnableNotifsViewControllerDelegate {

    @IBOutlet weak var codeLabel:UILabel!
    @IBOutlet weak var textField:UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var createGroupStackView:UIStackView!
    @IBOutlet weak var showCodeStackView:UIStackView!
    @IBOutlet weak var backButton: UIButton!
    
    private var navWasHidden = false
    
    // MARK: - Btn Actions
    @IBAction private func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction private func createGroup() {
        guard let text = self.textField.text where text.characters.count > 0 else {
            return
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.activityIndicator.startAnimating()
        
        
        let eventLabel = "\(NSUserDefaults.standardUserDefaults().stringForKey("ID"))"
        GA.sendEvent("group", action: "create", label: eventLabel, value: nil)
        NetworkingManager.sharedInstance.createGroup(text)
    }
    
    // MARK: - View Controller Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        self.setupTextField()
        
        // NetworkManager will send out notifications if the user join was successful
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CreateGroupViewController.groupCreated(_:)), name: NetworkingManager.Constants.USER_CREATED_GROUP, object: nil)

        self.navigationItem.setHidesBackButton(true, animated: false)
        self.showCodeStackView.alpha = 0
        self.showCodeStackView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let nvc = self.navigationController {
            self.navWasHidden = nvc.navigationBarHidden
            nvc.setNavigationBarHidden(true, animated: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let nvc = self.navigationController {
            nvc.setNavigationBarHidden(self.navWasHidden, animated: false)
        }
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
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func groupCreated(notification: NSNotification) {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            guard let userInfo = notification.userInfo else {
                return
            }
            
            guard let code = userInfo["code"] as? String else {
                return
            }
            
            self.codeLabel.text = code
            self.textField.resignFirstResponder()
            
            UIView.animateWithDuration(1.0, animations: {
                self.createGroupStackView.alpha = 0.0
                self.groupNameLabel.alpha = 0.0
                self.backButton.hidden = true
                }, completion: { done in
                    self.groupNameLabel.hidden = true
                    self.createGroupStackView.hidden = true
                    
                    self.showCodeStackView.hidden = false
                    self.showCodeStackView.bounceSlideUpIn(0.4, delay: 0)
            })
        })
    }
    
    // MARK: - Enable push notifications VC delegate
    func userDidMakeSelection() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction private func done() {
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
