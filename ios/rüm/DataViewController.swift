//
//  DataViewController.swift
//  rüm
//
//  Created by Andrew Fang on 4/21/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit
import Charts

class DataViewController: UIViewController, UICollectionViewDataSource, KudosButtonDelegate {
    
    var members: [[String: AnyObject]] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    struct Constants {
        static let MEMBER_DATA = "MEMBER_DATA"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register kudos page view with ga
        GA.registerPageView("Kudos")
        
        // don't allow scrolling to cancel touch events
        self.collectionView.canCancelContentTouches = false
        self.collectionView.delaysContentTouches = true
        
        let kudosFaceCellNib = UINib(nibName: "KudosFaceCell", bundle: nil)
        self.collectionView.registerNib(kudosFaceCellNib, forCellWithReuseIdentifier: "kudosFaceCell")
        self.collectionView.dataSource = self
        
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
        
        guard let m = userInfo["members"] as? [[String:AnyObject]] else {
            return
        }
        
        NSUserDefaults.standardUserDefaults().setValue(m, forKey: Constants.MEMBER_DATA)
        
        
        self.members = m
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
        })
    }
    
    // MARK:- Collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.members.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let kudosFaceCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("kudosFaceCell", forIndexPath: indexPath) as! KudosFaceCell
        kudosFaceCell.load(members[indexPath.row])
        kudosFaceCell.kudosButtonDelegate = self
        
        let loggedInUserId = NSUserDefaults.standardUserDefaults().stringForKey("ID")
        if kudosFaceCell.kudosButton.userId == loggedInUserId {
            kudosFaceCell.kudosButton.disabled = true
        }
        return kudosFaceCell
    }
    
    // MARK:- kudos button delegation
    var kudosStartTime: Double = 0.0
    func userDidBeginKudos(kudosButton: KudosButton) {
        kudosStartTime = NSDate().timeIntervalSince1970
    }
    
    func userDidEndKudos(kudosButton: KudosButton) {
        let total = NSDate().timeIntervalSince1970 - kudosStartTime
        
        // give kudos at a rate of 4 per second, + 1 to ensure that we
        // give at least 1
        let numKudos = Int(floor(total * 4) + 1)
        if let receiverId = kudosButton.userId {
            NetworkingManager.sharedInstance.giveKudos(receiverId, number: numKudos, completionHandler: nil)
            
            // "giver --> reciever"
            let eventLabel = "\(NSUserDefaults.standardUserDefaults().stringForKey("ID")) --> \(receiverId)"
            GA.sendEvent("task", action: "kudos", label: eventLabel, value: nil)
        }
    }
    
//    private func loadMembers(members: [[String:AnyObject]]) {
//        
//        for (_, member) in members.enumerate() {
//            let fullName = member["fullName"] as! String
//            let kudosCount = member["kudos"] as? Int
//            let userId = member["id"] as! String
//            let photoUrl = member["photo"] as? String
//        }
//        
//    }
    
//    private func showData(members:[[String:AnyObject]] ) {
//        
//        var dataEntries: [ChartDataEntry] = []
//        var titles:[String] = []
//        
//        for (i,member) in members.enumerate() {
//            titles.append(member["firstName"] as! String)
//            
//            var kudosCount:Double = 0
//            if let k = member["kudos"] as? Double {
//                kudosCount = k
//            }
//            dataEntries.append(BarChartDataEntry(value: kudosCount, xIndex: i))
//        }
//        
//        let colors = Array([UIColor.appBlue(), UIColor.appTeal(), UIColor.appRed(), UIColor.appOrange(), UIColor.appPurple(), UIColor.appYellow(), UIColor.blackColor()].prefix(titles.count))
//        let chartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
//        chartDataSet.colors = colors
//        NSOperationQueue.mainQueue().addOperationWithBlock({
//            self.pieChartView.descriptionText = ""
//            
//            if let joinCode = NSUserDefaults.standardUserDefaults().stringForKey("code") {
//                self.pieChartView.descriptionText = "Join code: \(joinCode)"
//            }
//            
//            self.pieChartView.data = PieChartData(xVals: titles, dataSet: chartDataSet)
//            self.pieChartView.setNeedsDisplay()
//        })
//    }
    
//    @IBAction private func logout() {
//        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?.", preferredStyle: .Alert)
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//        alertController.addAction(UIAlertAction(title: "Logout", style: .Destructive, handler: { done in
//            // yes
//            if let navVC = self.tabBarController?.viewControllers?.first as? UINavigationController {
//                if let mainVC = navVC.viewControllers.first as? MainViewController {
//                    mainVC.todos = []
//                    if mainVC.lastTaskCell != nil {
//                        mainVC.lastTaskCell!.loadEmpty()
//                    }
//                    mainVC.userId = nil
//                    mainVC.groupId = nil
//                    let userDef = NSUserDefaults.standardUserDefaults()
//                    userDef.setValue(nil, forKey: MainViewController.Constants.GROUP_ID)
//                    userDef.setValue(nil, forKey: "ID")
//                    
//                    mainVC.performSegueWithIdentifier("ShowLogin", sender: self)
//                    
//                    self.tabBarController?.selectedIndex = 0
//                }
//            }
//        }))
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
}
