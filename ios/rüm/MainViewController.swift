//
//  MainViewController.swift
//  rüm
//
//  Created by Andrew Fang on 4/21/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UICollectionViewDataSource, UICollectionViewDelegate {
    
    struct Constants {
        static let CHORE_CELL = "chore cell"
        static let ME_CELL = "task cell"
        static let GROUP_ID = "GROUP_ID"
    }
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var peopleJustProfileImageView: UIImageView!
    @IBOutlet weak var peopleJustNameLabel: UILabel!
    @IBOutlet weak var peopleJustTaskLabel: UILabel!
    @IBOutlet weak var peopleJustBackgroundImageView: UIImageView!
    @IBOutlet weak var kudosButton:UIButton!
    
    var lastCompletedTaskUserId:String?
    var quickTasks:[String]!
    var todos:[String]!
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.kudosButton.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.lastTask(_:)), name: NetworkingManager.Constants.LAST_TASK, object: nil)
        
        if let groupid = NSUserDefaults.standardUserDefaults().stringForKey(Constants.GROUP_ID) {
            NetworkingManager.sharedInstance.getGroupInfo(groupid)
            NetworkingManager.sharedInstance.generateCodeForGroup(groupid, userid: NSUserDefaults.standardUserDefaults().stringForKey("ID")!)
            // TODO: Something where we populate the quickTasks and todos
            self.quickTasks = Database.tasks
            self.todos = Database.tasks
        } else {
            self.performSegueWithIdentifier("ShowLogin", sender: self)
            self.quickTasks = []
            self.todos = []
        }
        
        self.getLastTask()
    }
    
    func setupTasks() {
        self.quickTasks = Database.tasks
        self.collectionView.reloadData()
    }
    
    func getLastTask() {
        // post notifcation, get back stuff
        if let groupid = NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID) {
            NetworkingManager.sharedInstance.getLastTask(groupid)
        }
    }
    
    func lastTask(notification:NSNotification) {
        guard let userInfo = notification.userInfo as? [String:AnyObject] else {
            return
        }
        
        guard let data = userInfo["data"] as? [String:String],
            user = userInfo["user"] as? [String:AnyObject] else {
                return
        }
        
        guard let firstName = user["firstName"] as? String,
            photoURL = user["photo"] as? String,
            action = data["title"] else {
                return
        }
        
        if let id = user["id"] as? String, savedid = NSUserDefaults.standardUserDefaults().stringForKey("ID") {
            // Don't let me give myself kudos
            self.kudosButton.hidden = id == savedid
            self.lastCompletedTaskUserId = id
        }
        
        self.someOneJustActioned(firstName, action: action, photo: photoURL)
    }
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.ME_CELL, forIndexPath: indexPath)
        
        if let cell = cell as? TaskCollectionViewCell {
            cell.taskImage.image = UIImage.imageFromTaskName(self.quickTasks[indexPath.item].lowercaseString)
            cell.taskName.text = self.quickTasks[indexPath.item]
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.quickTasks.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Change the banner to be what you just did
        
        // Show alert that you did good
        if let groupid = NSUserDefaults.standardUserDefaults().stringForKey(Constants.GROUP_ID),
            let id = NSUserDefaults.standardUserDefaults().stringForKey("ID") {
            NetworkingManager.sharedInstance.quickDoTask(groupid, creatorId: id, taskName: self.quickTasks[indexPath.item])
        }
        self.showAlert(withMessage: "You just \(self.quickTasks[indexPath.item].lowercaseString)!")
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CHORE_CELL, forIndexPath: indexPath)
        cell.textLabel?.text = self.todos[indexPath.item]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todos.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Handle Delete
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.todos.removeAtIndex(indexPath.item)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    @IBAction private func gaveKudos() {
        let labelSplit = self.peopleJustNameLabel.text!.characters.split{$0 == " "}.map(String.init)
        
        if let id = self.lastCompletedTaskUserId {
            NetworkingManager.sharedInstance.giveKudos(id, completionHandler: nil)
            self.showAlert(withMessage: "You just gave \(labelSplit[0]) kudos!")
        }
    }
    
    // Shows a popup with the given message
    private func showAlert(withMessage message:String) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Woohoo!", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func showJoinCode() {
        guard let code = NSUserDefaults.standardUserDefaults().stringForKey("code") else {
            return
        }
        let alertController = UIAlertController(title: code, message: "Share this code to invite people to this group.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - External facing methods
    // AppDelegate calls this method when a notification comes in
    func someOneJustActioned(name:String, action:String, photo: String) {
        
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.peopleJustNameLabel.text = "\(name) just..."
            self.peopleJustTaskLabel.text = action
            
            if let imageUrl = NSURL(string: photo) {
                if let data = NSData(contentsOfURL: imageUrl) {
                    self.peopleJustProfileImageView.image = UIImage(data: data)
                }
            }
            
            self.peopleJustBackgroundImageView.image = UIImage.imageFromTaskName(action.lowercaseString)
            
        })
    }
    
    
}

