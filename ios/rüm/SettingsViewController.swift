//
//  SettingsViewController.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/13/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var numberOfSections = 2
    var groupCode:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.clipsToBounds = true

        let cellNib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        self.tableView.registerNib(cellNib, forCellReuseIdentifier: "settingsTableViewCell")
//        self.tableView.registerNib(cellNib, forCellWithReuseIdentifier: "settingsTableViewCell")
        
        if let code = NSUserDefaults.standardUserDefaults().stringForKey("code") {
            self.groupCode = code
            self.numberOfSections = 2
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0 where numberOfSections == 2:
            return "JOIN CODE"
        case 1 where numberOfSections == 2:
            fallthrough
        case 0 where numberOfSections == 1:
            return "ACCOUNT"
        default:
            return ""
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("settingsTableViewCell") as! SettingsTableViewCell
        switch (indexPath.section) {
        case 0 where numberOfSections == 2:
            cell.label.text = "Code: \(self.groupCode)"
            cell.showArrow = true
        case 1 where numberOfSections == 2:
            fallthrough
        case 0 where numberOfSections == 1:
            cell.label.text = "Sign out"
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        
        if header.textLabel != nil{
            header.textLabel!.font = UIFont(name: "Avenir", size: 14)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section) {
        case 0 where numberOfSections == 2:
            let shareVc = UIActivityViewController(activityItems: ["Join my Kudös group with this code: \(self.groupCode)"], applicationActivities: nil)
            self.presentViewController(shareVc, animated: true, completion: nil)
        case 1 where numberOfSections == 2:
            fallthrough
        case 0 where numberOfSections == 1:
            logout()
        default:
            break
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    @IBAction private func logout() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Logout", style: .Destructive, handler: { done in
            // user tapped yes
            let mainVCIndex = 1
            if let navVC = self.tabBarController?.viewControllers?[mainVCIndex] as? UINavigationController {
                if let mainVC = navVC.viewControllers.first as? MainViewController {
                    mainVC.todos = []
                    if mainVC.lastTaskCell != nil {
                        mainVC.lastTaskCell!.loadEmpty()
                    }
                    mainVC.userId = nil
                    mainVC.groupId = nil
                    let userDef = NSUserDefaults.standardUserDefaults()
                    userDef.setValue(nil, forKey: MainViewController.Constants.GROUP_ID)
                    userDef.setValue(nil, forKey: "ID")
                    
                    mainVC.performSegueWithIdentifier("ShowLogin", sender: self)
                    self.tabBarController?.selectedIndex = mainVCIndex
                }
            }
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
