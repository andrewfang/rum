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
    
    var members: [[String: AnyObject]] = []
    
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
        
        let cornerRadius = kudosFaceCell.frame.size.width / 2.0
        kudosFaceCell.kudosButton.layer.cornerRadius = cornerRadius
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
