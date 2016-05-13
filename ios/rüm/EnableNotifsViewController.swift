//
//  EnableNotifsViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/13/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class EnableNotifsViewController: UIViewController {

    struct Constants {
        static let SETUP_NOTIF_SEGUE = "SETUP_NOTIF_SEGUE"
        static let NOTIF_REGISTER_SUCCESS = "NOTIF_REGISTER_SUCCESS"
        static let NOTIF_REGISTER_FAILED = "NOTIF_REGISTER_FAILED"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EnableNotifsViewController.registerNotifSuccess), name: Constants.NOTIF_REGISTER_SUCCESS, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EnableNotifsViewController.registerNotifFailed), name: Constants.NOTIF_REGISTER_FAILED, object: nil)
    }

    @IBAction private func showNotif() {
        NotificationManager.sharedInstance.registerForNotifications()
    }
    
    func registerNotifSuccess() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func registerNotifFailed() {
        print("Failed to register")
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
