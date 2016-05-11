//
//  MainViewController.swift
//  rüm
//
//  Created by Andrew Fang on 4/21/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate {
    
    struct Constants {
        static let CHORE_CELL = "chore cell"
        static let CHORE_ADD_CELL = "chore add new cell"
        static let ME_CELL = "task cell"
        static let GROUP_ID = "GROUP_ID"
    }
    
    @IBOutlet weak var tableView:UITableView!
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var peopleJustProfileImageView: UIImageView!
//    @IBOutlet weak var peopleJustNameLabel: UILabel!
//    @IBOutlet weak var peopleJustTaskLabel: UILabel!
//    @IBOutlet weak var peopleJustBackgroundImageView: UIImageView!
//    @IBOutlet weak var kudosButton:UIButton!
    
    var groupId:String!
    var userId:String!
    var lastCompletedTaskUserId:String?
    var quickTasks:[String]!
    var todos:[[String:AnyObject]]!
    var keyboardVisible:Bool = false
    var keyboardSize:CGFloat!
    
    var lastTaskCell:LastTaskCell?
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register main page view with ga
        GA.registerPageView("Main")
        
        let lastTaskNib = UINib(nibName: "LastTaskCell", bundle: nil)
        self.tableView.registerNib(lastTaskNib, forCellReuseIdentifier: "lastTaskCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
//        self.collectionView.dataSource = self
//        self.collectionView.delegate = self
//        self.kudosButton.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.lastTask(_:)), name: NetworkingManager.Constants.LAST_TASK, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.updateTodos(_:)), name: NetworkingManager.Constants.UPDATE_TODO, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        if let groupid = NSUserDefaults.standardUserDefaults().stringForKey(Constants.GROUP_ID),
        let userid = NSUserDefaults.standardUserDefaults().stringForKey("ID") {
            self.groupId = groupid
            self.userId = userid
            NetworkingManager.sharedInstance.login(self.userId, groupid: self.groupId)
            // TODO: Something where we populate the quickTasks and todos
            self.quickTasks = Database.tasks
            self.todos = []
        } else {
            self.performSegueWithIdentifier("ShowLogin", sender: self)
            self.quickTasks = []
            self.todos = []
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (self.groupId != nil) {
            self.getTodos()
            self.getLastTask()
        }
    }
    
    func setupTasks() {
        self.quickTasks = Database.tasks
//        self.collectionView.reloadData()
        if let groupid = NSUserDefaults.standardUserDefaults().stringForKey(Constants.GROUP_ID),
         let userid = NSUserDefaults.standardUserDefaults().stringForKey("ID")
        {
            self.groupId = groupid
            self.userId = userid
        }
        self.getLastTask()
    }
    
    func getTodos() {
        NetworkingManager.sharedInstance.getIncompleteTasks(self.groupId)
    }
    
    func updateTodos(notification:NSNotification) {
        guard let userInfo = notification.userInfo as? [String:AnyObject] else {
            return
        }
        
        if let data = userInfo["data"] as? [[String:AnyObject]] {
            self.todos = data.reverse()
            NSOperationQueue.mainQueue().addOperationWithBlock({
                self.tableView.reloadData()
            })
        }
    }
    
    func getLastTask() {
        // post notifcation, get back stuff
        if (self.groupId != nil) {
            NetworkingManager.sharedInstance.getLastTask(self.groupId)
        }
    }
    
    func lastTask(notification:NSNotification) {
        guard let userInfo = notification.userInfo as? [String:AnyObject] else {
            return
        }
        
        guard let data = userInfo["data"] as? [String:AnyObject],
            user = userInfo["user"] as? [String:AnyObject] else {
                NSOperationQueue.mainQueue().addOperationWithBlock({
//                    self.peopleJustBackgroundImageView.image = UIImage(named: "welcome")
//                    self.peopleJustProfileImageView.image = nil
//                    self.peopleJustTaskLabel.text = "Start by doing a task above or adding a new task below"
//                    self.peopleJustNameLabel.text = "Hello!"
//                    self.kudosButton.hidden = true
                })
                return
        }
        
        guard let firstName = user["firstName"] as? String,
            photoURL = user["photo"] as? String,
            action = data["title"] as? String else {
                return
        }
        
        if let id = user["id"] as? String {
            // Don't let me give myself kudos
            NSOperationQueue.mainQueue().addOperationWithBlock({
//                self.kudosButton.hidden = id == self.userId
                self.lastCompletedTaskUserId = id
            })
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
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
                if let data = UIImage.imageDataFromTaskName(self.quickTasks[indexPath.item].lowercaseString) {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        cell.taskImage.image = UIImage(data: data)
                    })
                }
            })
            
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
        if let id = NSUserDefaults.standardUserDefaults().stringForKey("ID") {
            let eventLabel = "\(NSUserDefaults.standardUserDefaults().stringForKey("ID"))"
            GA.sendEvent("task", action: "create-quick", label: eventLabel, value: nil)
            
            // NOTE: do event logging for completion in the networking manager, since it's a little tough
            // to get the task ID back. Should probably clean up
            NetworkingManager.sharedInstance.quickDoTask(self.groupId, creatorId: id, taskName: self.quickTasks[indexPath.item])
        }
        self.showAlert(withMessage: "You just \(self.quickTasks[indexPath.item].lowercaseString)!")
    }
    
    // MARK: - TableView
    
    // last task view, I just section, and remaining tasks
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Last task"
        }
        return ""
    }
    
    // 1 for the task view, 1 for the "I just..." section, and #tasks for the todo section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell?
        if indexPath.section == 0 {
            let lastTaskCell = self.tableView.dequeueReusableCellWithIdentifier("lastTaskCell", forIndexPath: indexPath) as! LastTaskCell
            self.lastTaskCell = lastTaskCell
            return lastTaskCell
        } else {
            cell = nil;
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // for the last task row, set the height of the cell 0.25 * the height of the window
        if indexPath.section == 0 {
            let windowHeight = self.view.window!.frame.size.height
            return 0.25 * windowHeight
        } else {
            return 0
        }
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        
//        // Put in the "add new" cell
//        if (indexPath.item == self.todos.count) {
//            if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CHORE_ADD_CELL, forIndexPath: indexPath) as? AddNewChoreTableViewCell {
//                cell.textField.delegate = self
//                return cell
//            }
//        }
//        
//        if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CHORE_CELL, forIndexPath: indexPath) as? ChoreTableViewCell {
//            cell.tintColor = UIColor.appRed()
//            cell.nameLabel.text = self.todos[indexPath.item]["title"] as? String
//            cell.checkbox.addTarget(self, action: #selector(MainViewController.checkOffItem(_:)), forControlEvents: .TouchUpInside)
//            cell.checkbox.tag = indexPath.item
//            cell.isChecked = false
//            cell.checkbox.userInteractionEnabled = true
//            // TODO: Add in imageview of person
//            let savedIndexPathItem = indexPath.item
//            if let assignee = self.todos[indexPath.item]["assignedTo"] as? [String: AnyObject] {
//                dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
//                    if let urlString = assignee["photo"] as? String {
//                        if let url = NSURL(string: urlString) {
//                            if let data = NSData(contentsOfURL: url) {
//                                if indexPath.item == savedIndexPathItem {
//                                    NSOperationQueue.mainQueue().addOperationWithBlock({
//                                        cell.assignedToImageView.image = UIImage(data: data)
//                                    })
//                                }
//                            }
//                        }
//                    }
//                })
//            } else {
//                cell.assignedToImageView.image = nil
//            }
//            return cell
//        }
//        
//        return tableView.dequeueReusableCellWithIdentifier(Constants.CHORE_CELL, forIndexPath: indexPath)
//    }
    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.todos.count + 1
//    }
//    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return indexPath.item < self.todos.count
//    }
//    
//    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("ASSIGN_TASK_SEGUE", sender: indexPath)
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "ASSIGN_TASK_SEGUE") {
//            guard let indexPath = sender as? NSIndexPath else {
//                return
//            }
//            if let navVC = segue.destinationViewController as? UINavigationController {
//                if let destVC = navVC.viewControllers.first as? AssignTaskViewController {
//                    destVC.task = self.todos[indexPath.item]
//                }
//            }
//        }
//    }
    
    // Handle Delete
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            NetworkingManager.sharedInstance.deleteTask(self.groupId, taskId: self.todos[indexPath.item]["id"] as! String)
            self.todos.removeAtIndex(indexPath.item)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    // complete a task
    func checkOffItem(sender: UIButton) {
        if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as? ChoreTableViewCell {
            cell.isChecked = !cell.isChecked
            let triggerTime = (Int64(NSEC_PER_SEC) * 1)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.toggleItemsCompleted()
            })
        }
    }
    
    func toggleItemsCompleted() {
        for i in 0 ... self.todos.count {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? ChoreTableViewCell {
                if (cell.isChecked) {
                    let taskId = self.todos[i]["id"] as! String
                    // send a GA event on task completion
                    let label = "\(self.userId) : \(taskId)"
                    GA.sendEvent("task", action: "complete", label: label, value: nil)
                    NetworkingManager.sharedInstance.completeTask(self.groupId, taskId: taskId, userId: self.userId)
                }
            }
        }
    }
    
    // TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if let text = textField.text where text.characters.count > 0 {
            
            let eventLabel = "\(NSUserDefaults.standardUserDefaults().stringForKey("ID"))"
            GA.sendEvent("task", action: "create", label: eventLabel, value: nil)
            
            NetworkingManager.sharedInstance.createTask(self.groupId, taskName: text)
            self.todos.append(["title":text])
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.todos.count, inSection: 0)], withRowAnimation: .Automatic)
            self.getTodos()
            textField.text = ""
        }
        return true
    }
    
    func keyboardDidShow(notification: NSNotification) {
        self.keyboardVisible = true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (!self.keyboardVisible) {
            if let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size {
                self.keyboardSize = keyboardSize.height
                
                let diff = keyboardSize.height
                if diff > 0 {
                    UIView.animateWithDuration(0.3, animations: {
                        var frame = self.view.frame
                        frame.origin.y = frame.origin.y - diff
                        self.view.frame = frame
                    })
                }
            }
            self.keyboardVisible = true
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (self.keyboardVisible) {
            if let keyboardSize = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size {
                
                let diff = keyboardSize.height
                
                if diff > 0 {
                    UIView.animateWithDuration(0.3, animations: {
                        var frame = self.view.frame
                        frame.origin.y = frame.origin.y + diff
                        self.view.frame = frame
                    })
                }
            }
            self.keyboardVisible = false
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        self.keyboardVisible = false
    }
    
    
    @IBAction private func gaveKudos() {
        // TODO: uncomment
//        let labelSplit = self.peopleJustNameLabel.text!.characters.split{$0 == " "}.map(String.init)
        let labelSplit = [""]
        
        if let id = self.lastCompletedTaskUserId {
            NetworkingManager.sharedInstance.giveKudos(id, completionHandler: nil)
            
            // "giver --> reciever"
            // TODO: may want to include task ID
            let eventLabel = "\(NSUserDefaults.standardUserDefaults().stringForKey("ID")) --> \(id)"
            GA.sendEvent("task", action: "kudos", label: eventLabel, value: nil)
            
            self.showAlert(withMessage: "You just gave \(labelSplit[0]) kudos!")
        }
    }
    
    @IBAction private func switchGroups() {
        self.performSegueWithIdentifier("GROUP_SWITCH", sender: nil)
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
            if (self.lastTaskCell != nil) {
                self.lastTaskCell!.loadTask(name, task: action, photo: photo)
            }
        })
    }
}

