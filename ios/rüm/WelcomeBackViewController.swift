//
//  WelcomeBackViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/3/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class WelcomeBackViewController: UIViewController {

    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var photoImgView:UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoImgView.image = FacebookManager.sharedInstance.photo
        self.nameLabel.text = "Welcome back, \(FacebookManager.sharedInstance.first_name!)"
    }
    
    @IBAction func start() {
        NotificationManager.sharedInstance.registerForNotifications()
        
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
