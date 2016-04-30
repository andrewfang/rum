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
    
    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var photoImgView:UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login() {
        FacebookManager.sharedInstance.login(self)
    }
    
    override func notifyLoggedIn() {
        self.photoImgView.image = FacebookManager.sharedInstance.photo
        self.nameLabel.text = FacebookManager.sharedInstance.username

        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
