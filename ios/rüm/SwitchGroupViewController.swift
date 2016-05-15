//
//  SwitchGroupViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/6/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class SwitchGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var photoImgView:UIImageView!
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    
    @IBAction private func cancel() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var groups:[[String:AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = .BlackTranslucent
        
        // register switch group page view with ga
        GA.registerPageView("SwitchGroup")
        
        NetworkingManager.sharedInstance.getUserInfo(NSUserDefaults.standardUserDefaults().stringForKey("ID")!)
        self.photoImgView.image = FacebookManager.sharedInstance.photo
        self.nameLabel.text = "Hey \(FacebookManager.sharedInstance.first_name!)!"
        
        let groupCellNib = UINib(nibName: "GroupCell", bundle: nil)
        self.tableView.registerNib(groupCellNib, forCellReuseIdentifier: "groupCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwitchGroupViewController.loadUsersGroups(_:)), name: NetworkingManager.Constants.GET_USER_INFO, object: nil)
        self.spinner.startAnimating()
        
        
        self.createButton.layer.borderWidth = 1
        self.createButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.joinButton.layer.borderWidth = 1
        self.joinButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        self.tableView.clipsToBounds = true
        self.tableView.layer.masksToBounds = false
        self.tableView.layer.shadowColor = UIColor.blackColor().CGColor
        self.tableView.layer.shadowOffset = CGSizeMake(0, 2)
        self.tableView.layer.shadowRadius = 1.0
        self.tableView.layer.shadowOpacity = 0.1
        
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            // always fill the view
            blurEffectView.frame = self.photoImgView.bounds
            blurEffectView.alpha = 0.6
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.photoImgView.insertSubview(blurEffectView, atIndex: 1)
        }
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    
    func loadUsersGroups(notification:NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        guard let groups = userInfo["groups"] as? [ [String:AnyObject]] else {
            return
        }
        self.groups = groups
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.spinner.stopAnimating()
            self.tableView.reloadData()
        })
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath)

        if let cell = cell as? GroupCell {
            cell.groupNameLabel.text = groups[indexPath.item]["name"] as? String
        }
        
        return cell
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSUserDefaults.standardUserDefaults().setValue(self.groups[indexPath.item]["id"] as! String, forKey: MainViewController.Constants.GROUP_ID)
        NetworkingManager.sharedInstance.generateCodeForGroup(self.groups[indexPath.item]["id"] as! String)
        if let tabvc = self.presentingViewController as? UITabBarController {
            if let navvc = tabvc.viewControllers![1] as? UINavigationController {
                if let mainvc = navvc.viewControllers.first as? MainViewController {
                    mainvc.setupTasks()
                }
            }
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
