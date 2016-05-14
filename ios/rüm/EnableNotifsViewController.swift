//
//  EnableNotifsViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/13/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

protocol EnableNotifsViewControllerDelegate: class {
    func userDidMakeSelection()
}

class EnableNotifsViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var phoneIcon: UIImageView!
    
    @IBOutlet weak var enableButton: UIButton!
    @IBOutlet weak var notNowButton: UIButton!
    @IBOutlet weak var copyLabel: UILabel!
    
    struct Constants {
        static let SETUP_NOTIF_SEGUE = "SETUP_NOTIF_SEGUE"
        static let NOTIF_REGISTER_SUCCESS = "NOTIF_REGISTER_SUCCESS"
        static let NOTIF_REGISTER_FAILED = "NOTIF_REGISTER_FAILED"
    }

    var delegate: EnableNotifsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .Default
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EnableNotifsViewController.registerNotifSuccess), name: Constants.NOTIF_REGISTER_SUCCESS, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EnableNotifsViewController.registerNotifFailed), name: Constants.NOTIF_REGISTER_FAILED, object: nil)
        
        // animations
        headerLabel.bounceSlideUpIn(0.4, delay: 0.4)
        phoneIcon.bounceIn(0.4, delay: 0.6)
        
        copyLabel.bounceSlideUpIn(0.4, delay: 0.6)
        enableButton.bounceSlideUpIn(0.4, delay: 0.8)
        notNowButton.bounceSlideUpIn(0.4, delay: 1.0)
        
    }

    @IBAction private func showNotif() {
        NotificationManager.sharedInstance.registerForNotifications()
        if (self.delegate != nil) {
            self.delegate!.userDidMakeSelection()
        }
    }
    
    @IBAction private func noNotif() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        if (self.delegate != nil) {
            self.delegate!.userDidMakeSelection()
        }
    }
    
    func registerNotifSuccess() {
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }
    
    func registerNotifFailed() {
        print("Failed to register")
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    
}
