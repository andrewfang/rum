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
    
    @IBAction private func cancel() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var groups:[[String:AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register switch group page view with ga
        GA.registerPageView("SwitchGroup")
        
        NetworkingManager.sharedInstance.getUserInfo(NSUserDefaults.standardUserDefaults().stringForKey("ID")!)
        self.photoImgView.image = FacebookManager.sharedInstance.photo
        self.nameLabel.text = "Hi, \(FacebookManager.sharedInstance.first_name!)"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwitchGroupViewController.loadUsersGroups(_:)), name: NetworkingManager.Constants.GET_USER_INFO, object: nil)
        self.spinner.startAnimating()
        
        self.tableView.clipsToBounds = false
        self.tableView.layer.masksToBounds = false
        self.tableView.layer.shadowColor = UIColor.blackColor().CGColor
        self.tableView.layer.shadowOffset = CGSizeMake(0, 1)
        self.tableView.layer.shadowRadius = 2.0
        self.tableView.layer.shadowOpacity = 0.3
        
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.alpha = 0.8
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            self.view.insertSubview(blurEffectView, atIndex: 1)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("group cell", forIndexPath: indexPath)
        
        if let cell = cell as? GroupTableViewCell {
            cell.groupName.text = groups[indexPath.item]["name"] as? String
        }
        
        return cell
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
            if let navvc = tabvc.viewControllers?.first as? UINavigationController {
                if let mainvc = navvc.viewControllers.first as? MainViewController {
                    mainvc.setupTasks()
                }
            }
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
