//
//  MainViewController.swift
//  rüm
//
//  Created by Andrew Fang on 4/21/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, TextInputViewControllerDelegate, TodoCellDelegate {
    
    struct Constants {
        static let CHORE_CELL = "chore cell"
        static let CHORE_ADD_CELL = "chore add new cell"
        static let ME_CELL = "task cell"
        static let GROUP_ID = "GROUP_ID"
    }
    
    let TODO_SECTION = 2
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var addTaskButton: UIButton!
    
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
    var quickCompleteCell:QuickCompleteCell?
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register main page view with ga
        GA.registerPageView("Main")
        
        // don't allow scrolling to cancel touch events
        self.tableView.canCancelContentTouches = false
        self.tableView.delaysContentTouches = true
        
        let lastTaskNib = UINib(nibName: "LastTaskCell", bundle: nil)
        self.tableView.registerNib(lastTaskNib, forCellReuseIdentifier: "lastTaskCell")
        
        let quickCompleteCellNib = UINib(nibName: "QuickCompleteCell", bundle: nil)
        self.tableView.registerNib(quickCompleteCellNib, forCellReuseIdentifier: "quickCompleteCell")
        
        let todoCellNib = UINib(nibName: "TodoCell", bundle: nil)
        self.tableView.registerNib(todoCellNib, forCellReuseIdentifier: "todoCell")
        
        addTaskButton.layer.masksToBounds = false
        addTaskButton.layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.18).CGColor
        addTaskButton.layer.shadowOffset = CGSizeMake(0.0, 4.0)
        addTaskButton.layer.shadowOpacity = 1
        
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
        if (self.quickCompleteCell != nil) {
            self.quickCompleteCell?.collectionView.reloadData()
        }
        
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
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
        return 3
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = NSBundle.mainBundle().loadNibNamed("TableSectionHeaderView", owner: self, options: nil).first as? TableSectionHeaderView
        switch section {
            case 0: return nil
            case 1:
                if (headerView != nil) {
                    headerView!.headerLabel.text = "I JUST..."
                    return headerView
                }
                return nil
            case TODO_SECTION:
                if (headerView != nil) {
                    headerView!.headerLabel.text = "TODO"
                    return headerView
                }
                return nil
            default: return nil
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
            // no header for last task
            case 0: return 0
            default: return 43
        }
    }
    
    // 1 for the task view, 1 for the "I just..." section, and #tasks for the todo section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0, 1: return 1
            default: return self.todos.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                // last task cell
                let lastTaskCell = self.tableView.dequeueReusableCellWithIdentifier("lastTaskCell", forIndexPath: indexPath) as! LastTaskCell
                self.lastTaskCell = lastTaskCell
                return lastTaskCell
            case 1:
                // quick complete cell
                let quickCompleteCell = self.tableView.dequeueReusableCellWithIdentifier("quickCompleteCell", forIndexPath: indexPath) as! QuickCompleteCell
                self.quickCompleteCell = quickCompleteCell
                quickCompleteCell.tasks = self.quickTasks
                quickCompleteCell.collectionViewDelegate = self
                return quickCompleteCell
            default:
                // todo cell
                // grab the task data from the JSON and load the data into the cell
                // before returning it
                let todoCell = self.tableView.dequeueReusableCellWithIdentifier("todoCell", forIndexPath: indexPath) as! TodoCell
                let taskId = self.todos[indexPath.item]["id"] as? String
                let taskTitle = self.todos[indexPath.item]["title"] as? String
                let assignee  = self.todos[indexPath.item]["assignedTo"] as? [String : AnyObject]
                todoCell.delegate = self
                todoCell.loadTask(taskId, title: taskTitle, assignedTo: assignee)
                return todoCell
    
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // for the last task row, set the height of the cell 0.25 * the height of the window
        switch indexPath.section {
            case 0:
                if (self.view.window != nil) {
                    let windowHeight = self.view.window!.frame.size.height
                    return 0.25 * windowHeight
                } else {
                    return 100
                }
            case 1:
                return 84
            default: return 66
            
        }
    }
    
    // MARK: - TodoCell delegation
    func getTodoIndexPath(taskId:String) -> NSIndexPath? {
        // find index path for deleted table cell
        var indexPath: NSIndexPath?
        // number of rows in todo section
        let numRows = self.todos.count
        for i in 0 ..< numRows {
            if let id = self.todos[i]["id"] as? String {
                if id == taskId {
                    indexPath = NSIndexPath.init(forRow: i, inSection: TODO_SECTION)
                    break
                }
            }
        }
        return indexPath
    }
    
    func userDidCompleteTodo(todoCell: TodoCell) {
        let taskId = todoCell.taskId
        if (taskId != nil) {
            // get index path for completed task
            let indexPath = getTodoIndexPath(taskId!)
            if indexPath != nil {
                let label = "\(self.userId) : \(taskId)"
                GA.sendEvent("task", action: "complete", label: label, value: nil)
                NetworkingManager.sharedInstance.completeTask(self.groupId, taskId: taskId!, userId: self.userId)
                
                self.todos.removeAtIndex(indexPath!.row)
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.endUpdates()
            }
        }
    }
    
    func userDidDeleteTodo(todoCell: TodoCell) {
        let taskId = todoCell.taskId
        if (taskId != nil) {
            
            // find index path for deleted table cell
            let indexPath = getTodoIndexPath(taskId!)
            if indexPath != nil {
                NetworkingManager.sharedInstance.deleteTask(self.groupId, taskId: taskId!)
                
                self.todos.removeAtIndex(indexPath!.row)
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.endUpdates()
            }
        }
    }
    
    // MARK: - TextInputViewController delegation
    func userDidInputText(text: String?) {
        if (text != nil) {
            let trimmed = text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if trimmed.characters.count > 0 {
                createTask(trimmed)
            }
        }
    }
    
    // MARK: - Create task
    func createTask(title: String) {
        if title.characters.count > 0 {
            let eventLabel = "\(NSUserDefaults.standardUserDefaults().stringForKey("ID"))"
            GA.sendEvent("task", action: "create", label: eventLabel, value: nil)
            
            NetworkingManager.sharedInstance.createTask(self.groupId, taskName: title)
            
            // TODO should wait on a response from the API before appending, then add it
            // with its generated task ID
            self.todos.append(["title": title])
            self.getTodos()
        }
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
    
    
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ASSIGN_TASK_SEGUE") {
            guard let indexPath = sender as? NSIndexPath else {
                return
            }
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let destVC = navVC.viewControllers.first as? AssignTaskViewController {
                    destVC.task = self.todos[indexPath.item]
                }
            }
        } else if segue.identifier == "AddTaskSegue" {
            print(segue.destinationViewController)
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let textVC = navVC.viewControllers.first as? TextInputViewController {
                    textVC.labelText = "Task title"
                    textVC.navTitle = "Create a task"
                    textVC.delegate = self
                }
            }
        }
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

