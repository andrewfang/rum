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
    }

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var peopleJustProfileImageView: UIImageView!
    @IBOutlet weak var peopleJustNameLabel: UILabel!
    @IBOutlet weak var peopleJustTaskLabel: UILabel!
    @IBOutlet weak var peopleJustBackgroundImageView: UIImageView!
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.ME_CELL, forIndexPath: indexPath)
        
        if let cell = cell as? TaskCollectionViewCell {
            cell.taskImage.image = UIImage(named: Database.tasks[indexPath.item].lowercaseString)
            cell.taskName.text = Database.tasks[indexPath.item]
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Database.tasks.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Change the banner to be what you just did
        self.peopleJustNameLabel.text = "You just..."
        self.peopleJustTaskLabel.text = Database.tasks[indexPath.item]
        self.peopleJustProfileImageView.image = UIImage(named: "Andrew")
        self.peopleJustBackgroundImageView.image = UIImage(named: Database.tasks[indexPath.item].lowercaseString)
        
        // Show alert that you did good
        self.showAlert(withMessage: "You just \(Database.tasks[indexPath.item].lowercaseString)!")
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CHORE_CELL, forIndexPath: indexPath)
        cell.textLabel?.text = Database.chores[indexPath.item]
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Database.chores.count
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Handle Delete
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            Database.chores.removeAtIndex(indexPath.item)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    @IBAction private func gaveKudos() {
        let labelSplit = self.peopleJustNameLabel.text!.characters.split{$0 == " "}.map(String.init)
        let name = labelSplit[0] == "You" ? "yourself" : labelSplit[0]
        
        self.showAlert(withMessage: "You just gave \(name) kudos!")
    }
    
    // Shows a popup with the given message
    private func showAlert(withMessage message:String) {
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Woohoo!", style: .Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - External facing methods
    // AppDelegate calls this method when a notification comes in
    func someOneJustActioned(name:String, action:String) {
        self.peopleJustNameLabel.text = "\(name) just..."
        self.peopleJustTaskLabel.text = action
        self.peopleJustProfileImageView.image = UIImage(named: name)
        self.peopleJustBackgroundImageView.image = UIImage(named: action.lowercaseString)
    }
    
    
}

