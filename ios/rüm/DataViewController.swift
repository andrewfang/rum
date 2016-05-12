//
//  DataViewController.swift
//  rüm
//
//  Created by Andrew Fang on 4/21/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit
import Charts

class DataViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, KudosButtonDelegate {
    
    var renderedKudosGraph = false
    var members: [[String: AnyObject]] = []
    var faceCells: [String: KudosFaceCell] = [:]
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        self.collectionView.delegate = self
        
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
            self.activityIndicator.hidden = true
            
            // update graph after layout pass
            dispatch_async(dispatch_get_main_queue(), {
                self.updateKudosGraphs()
            })
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
        
        if let userId = members[indexPath.row]["id"] as? String {
            self.faceCells[userId] = kudosFaceCell
        }
        
        kudosFaceCell.kudosButtonDelegate = self
        
        let loggedInUserId = NSUserDefaults.standardUserDefaults().stringForKey("ID")
        if kudosFaceCell.kudosButton.userId == loggedInUserId {
            kudosFaceCell.kudosButton.disabled = true
        } else {
            kudosFaceCell.kudosButton.disabled = false
        }
        
        let cornerRadius = kudosFaceCell.frame.size.width / 2.0
        kudosFaceCell.kudosButton.layer.cornerRadius = cornerRadius
        
        let delay = Double(arc4random_uniform(10)) * 0.05
        kudosFaceCell.bounceIn(0.8, delay: delay)
        kudosFaceCell.bounceSlideUpIn(0.8, delay: 0)
        
        return kudosFaceCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if self.view.window != nil {
            // subtract 40pt margins on sides and 40pt for space between 
            // buttons
            let space = self.view.window!.frame.size.width - (40 * 2) - 40
            let width = space / 2.0
            let height = width * 1.25
            return CGSize(width: width, height: height)
        }
        
        // default size
        return CGSize(width: 120, height: 150)
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
    
    func updateKudosGraphs() {
        
        let membersCopy = self.members.sort({ (m1: [String: AnyObject], m2: [String: AnyObject]) -> Bool in
            var k1 = m1["kudos"] as? Int
            var k2 = m2["kudos"] as? Int
            
            k1 = k1 == nil ? 0 : k1
            k2 = k2 == nil ? 0 : k2
            
            return k1 < k2
        })
        
        let ids = membersCopy.map({ (m: [String: AnyObject]) -> String in
            return m["id"] as! String
        })
        
        let kudos = membersCopy.map({ (m: [String: AnyObject]) -> Int in
            if let k = m["kudos"] as? Int {
                return k
            } else {
                return 0
            }
        })
        
        var max = kudos.maxElement()
        if max == nil {
            max = 1
        }
        
        let graphColors = UIColor.rumGraphColors()
        for i in 0...(self.members.count - 1) {
            let k = kudos[i]
            let id = ids[i]
            let color = graphColors[i % graphColors.count]
            let value:CGFloat = CGFloat(k) / CGFloat(max!)
            
            if let faceCell = self.faceCells[id] {
//                // if the items haven't been bounced in before
//                if !self.renderedKudosGraph {
//                    faceCell.bounceIn(0.8)
//                    self.renderedKudosGraph = true
//                }
                
                faceCell.kudosGraphView.color = color
                faceCell.kudosGraphView.setValue(value, duration: 1.4, delay: 0.0)
            }
        }
    }
    
    
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
