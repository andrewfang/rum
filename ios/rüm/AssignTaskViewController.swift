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
    
    @IBOutlet weak var profileView:UIImageView!
    @IBOutlet weak var backgroundView:UIImageView!
    @IBOutlet weak var backgroundOverlayView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var assignedToNameLabel:UILabel!
    
    var selected:[String:AnyObject]? {
        didSet {
            if let s = selected {
                self.assignedToNameLabel.text = s["fullName"] as? String
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)){
                    // CHECK THIS -- NO WIFI
                    if let urlString = s["photo"] as? String {
                        if let url = NSURL(string: urlString) {
                            if let data = NSData(contentsOfURL: url) {
                                NSOperationQueue.mainQueue().addOperationWithBlock({
                                    self.profileView.hidden = false
                                    self.profileView.image = UIImage(data: data)
                                })
                            }
                        }
                    }
                }
            } else {
                self.assignedToNameLabel.text = "Nobody"
                self.profileView.hidden = true
            }
        }
    }
    
    var members = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register assign task page view with ga
        GA.registerPageView("AssignTask")
        
        self.title = self.task["title"] as? String
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if let data = UIImage.imageDataFromTaskName(self.task["title"] as! String) {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.backgroundView.image = UIImage(data: data)
                })
            }
        })
        
        // make nav transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.clipsToBounds = true
        self.tableView.layer.masksToBounds = false
        self.tableView.layer.shadowColor = UIColor.blackColor().CGColor
        self.tableView.layer.shadowOffset = CGSizeMake(0, 2)
        self.tableView.layer.shadowRadius = 1.0
        self.tableView.layer.shadowOpacity = 0.1
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AssignTaskViewController.updateData(_:)), name: NetworkingManager.Constants.GROUP_DATA, object: nil)
        
        if let assignee = self.task["assignedTo"] as? [String:AnyObject] {
            self.profileView.hidden = false
            self.selected = assignee
            self.profileView.layer.cornerRadius = 50
            self.profileView.layer.borderWidth = 4
            self.profileView.layer.borderColor = UIColor.whiteColor().CGColor
        } else {
            self.profileView.hidden = true
        }
        
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            // always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.alpha = 0.8
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.view.insertSubview(blurEffectView, atIndex: 2)
        }
        
        
        if let members = NSUserDefaults.standardUserDefaults().valueForKey(DataViewController.Constants.MEMBER_DATA) {
            self.members = members as! [[String : AnyObject]]
        } else {
            NetworkingManager.sharedInstance.getGroupForData(NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID)!)
        }
    }
    
    @IBAction private func done() {
        self.doneChoosing()
    }
    
    private func doneChoosing() {
        // Network call
        var assignedTo:String? = nil
        if let s = self.selected {
            assignedTo = s["id"] as? String
            
            // send GA assign event
            // "assigner --> assignedTo : taskId"
            let eventLabel = "\(NSUserDefaults.standardUserDefaults().stringForKey("ID")) --> \(assignedTo) : \(self.task["id"])"
            GA.sendEvent("task", action: "assign", label: eventLabel, value: nil)
        }
        NetworkingManager.sharedInstance.assignTask(NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID)!, taskId: self.task["id"]! as! String, assignToId: assignedTo)
        
        if let tabVC = self.presentingViewController as? UITabBarController {
            if let navVC = tabVC.viewControllers?.first as? UINavigationController {
                if let vc = navVC.viewControllers.first as? MainViewController {
                    dispatch_async(dispatch_get_main_queue(), {
                        vc.tableView.reloadData()
                    })
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
        
        self.doneChoosing()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("member cell", forIndexPath: indexPath)
        cell.tintColor = UIColor.rumBlack()
        
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
                        if indexPath.item == savedIndexPathItem {
                            cell.personImage.hnk_setImageFromURL(url)
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
        self.members = members
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }

}
