//
//  DataViewController.swift
//  rüm
//
//  Created by Andrew Fang on 4/21/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit
import Charts

class DataViewController: UIViewController {
    
    struct Constants {
        static let MEMBER_DATA = "MEMBER_DATA"
    }

    @IBOutlet weak var pieChartView: PieChartView!{
        didSet {
            guard let members = NSUserDefaults.standardUserDefaults().valueForKey(Constants.MEMBER_DATA) as? [[String:AnyObject]] else {
                return
            }
            
            self.showData(members)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DataViewController.updateData(_:)), name: NetworkingManager.Constants.GROUP_DATA, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NetworkingManager.sharedInstance.getGroupForData(NSUserDefaults.standardUserDefaults().stringForKey(MainViewController.Constants.GROUP_ID)!)
    }
    
    func updateData(notification:NSNotification) {
        guard let userInfo = notification.userInfo as? [String:AnyObject] else {
            return
        }
        
        guard let members = userInfo["members"] as? [[String:AnyObject]] else {
            return
        }
        
        
        
        NSUserDefaults.standardUserDefaults().setValue(members, forKey: Constants.MEMBER_DATA)
        
        self.showData(members)
    }
    
    private func showData(members:[[String:AnyObject]] ) {
        
        var dataEntries: [ChartDataEntry] = []
        var titles:[String] = []
        
        for (i,member) in members.enumerate() {
            titles.append(member["firstName"] as! String)
            
            var kudosCount:Double = 0
            if let k = member["kudos"] as? Double {
                kudosCount = k
            }
            dataEntries.append(BarChartDataEntry(value: kudosCount, xIndex: i))
        }
        
        let colors = Array([UIColor.appBlue(), UIColor.appTeal(), UIColor.appRed(), UIColor.appOrange(), UIColor.appPurple(), UIColor.appYellow(), UIColor.blackColor()].prefix(titles.count))
        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.colors = colors
        NSOperationQueue.mainQueue().addOperationWithBlock({
            self.pieChartView.descriptionText = ""
            
            if let joinCode = NSUserDefaults.standardUserDefaults().stringForKey("code") {
                self.pieChartView.descriptionText = "Join code: \(joinCode)"
            }
            
            self.pieChartView.data = PieChartData(xVals: titles, dataSet: chartDataSet)
            self.pieChartView.setNeedsDisplay()
        })
    }
    
    @IBAction private func logout() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?.", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Logout", style: .Destructive, handler: { done in
            // yes
            if let navVC = self.tabBarController?.viewControllers?.first as? UINavigationController {
                if let mainVC = navVC.viewControllers.first as? MainViewController {
                    mainVC.todos = []
                    mainVC.someOneJustActioned("Hello", action: "Start by doing a task above or adding a new task below", photo: "")
                    mainVC.userId = nil
                    mainVC.groupId = nil
                    let userDef = NSUserDefaults.standardUserDefaults()
                    userDef.setValue(nil, forKey: MainViewController.Constants.GROUP_ID)
                    userDef.setValue(nil, forKey: "ID")
                    
                    self.tabBarController?.selectedIndex = 0
                }
            }
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
