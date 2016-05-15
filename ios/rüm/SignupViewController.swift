//
//  SignupViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/3/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var photoImgView:UIImageView!
    
    private struct Constants {
        static let CREATE_SEGUE = "CREATE_SEGUE"
        static let JOIN_SEGUE = "JOIN_SEGUE"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        self.photoImgView.image = FacebookManager.sharedInstance.photo
        self.nameLabel.text = "Hi, \(FacebookManager.sharedInstance.first_name!)"
    }
    
    @IBAction func create() {
        self.performSegueWithIdentifier(Constants.CREATE_SEGUE, sender: nil)
    }
    
    @IBAction func join() {
        self.performSegueWithIdentifier(Constants.JOIN_SEGUE, sender: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}
