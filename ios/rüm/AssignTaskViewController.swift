//
//  AssignTaskViewController.swift
//  rüm
//
//  Created by Andrew Fang on 5/8/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class AssignTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var task:[String:AnyObject]!
    
    @IBOutlet weak var taskImage:UIImageView!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var assignedToNameLabel:UILabel!
    
    var selected:[String:AnyObject]? {
        didSet {
            if let s = selected {
                self.assignedToNameLabel.text = "Assigned to \(s["fullName"] as! String)"
            } else {
                self.assignedToNameLabel.text = "Not assigned to anyone"
            }
        }
    }
    
    var members = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.taskNameLabel.text = self.task["title"] as? String
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if let data = UIImage.imageDataFromTaskName(self.task["title"] as! String) {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.taskImage.image = UIImage(data: data)
                })
            }
        })
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AssignTaskViewController.updateData(_:)), name: NetworkingManager.Constants.GROUP_DATA, object: nil)
        
        if let assignee = self.task["assignedTo"] as? [String:AnyObject] {
            self.selected = assignee
        }
        
        
        if let members = NSUserDefaults.standardUserDefaults().valueForKey(DataViewController.Constants.MEMBER_DATA) {
            self.members = members as! [[String : AnyObject]]
        } else {
            NetworkingManager.sharedInstance.getGroupForData(NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID)!)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }
    
    @IBAction private func done() {
        // Network call
        var assignedTo:String? = nil
        if let s = self.selected {
            assignedTo = s["id"] as? String
        }
        NetworkingManager.sharedInstance.assignTask(NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID)!, taskId: self.task["id"]! as! String, assignToId: assignedTo)
        
        if let tabVC = self.presentingViewController as? UITabBarController {
            if let navVC = tabVC.viewControllers?.first as? UINavigationController {
                if let vc = navVC.viewControllers.first as? MainViewController {
                    vc.tableView.reloadData()
                }
            }
        }
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction private func cancel() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let s = selected where s["id"] as! String == self.members[indexPath.item]["id"] as! String {
            self.selected = nil
        } else {
            
            self.selected = self.members[indexPath.item]
        }
        
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("member cell", forIndexPath: indexPath)
        cell.tintColor = UIColor.appRed()
        
        if let s = selected where s["id"] as! String == self.members[indexPath.item]["id"] as! String {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        if let cell = cell as? MemberTableViewCell {
            let savedIndexPathItem = indexPath.item
            cell.personNameLabel.text = self.members[indexPath.item]["fullName"] as? String
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
                if let urlString = self.members[indexPath.item]["photo"] as? String {
                    if let url = NSURL(string: urlString) {
                        if let data = NSData(contentsOfURL: url) {
                            if indexPath.item == savedIndexPathItem {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    cell.personImage.image = UIImage(data: data)
                                })
                            }
                        }
                    }
                }
            })
        }
        return cell
    }
    
    func updateData(notification:NSNotification) {
        guard let userInfo = notification.userInfo as? [String:AnyObject] else {
            return
        }
        
        guard let members = userInfo["members"] as? [[String:AnyObject]] else {
            return
        }
        
        NSUserDefaults.standardUserDefaults().setValue(members, forKey: DataViewController.Constants.MEMBER_DATA)
        self.tableView.reloadData()
    }

}
