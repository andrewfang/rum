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
    
    var groups:[[String:AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkingManager.sharedInstance.getUserInfo(NSUserDefaults.standardUserDefaults().stringForKey("ID")!)
        self.photoImgView.image = FacebookManager.sharedInstance.photo
        self.nameLabel.text = "Hi, \(FacebookManager.sharedInstance.first_name!)"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwitchGroupViewController.loadUsersGroups(_:)), name: NetworkingManager.Constants.GET_USER_INFO, object: nil)
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
