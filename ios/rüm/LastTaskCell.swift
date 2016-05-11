//
//  LastTaskCell.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/10/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class LastTaskCell: UITableViewCell {

    @IBOutlet weak var attributionLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        // no selected state, want to make sure nothing happens here
//        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func loadTask(name:String, task:String, photo:String) {
        attributionLabel.text = "\(name) completed a task"
        taskLabel.text = task
        if let imageUrl = NSURL(string: photo) {
            if let data = NSData(contentsOfURL: imageUrl) {
                self.profileImageView.image = UIImage(data: data)
            }
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if let data = UIImage.imageDataFromTaskName(task.lowercaseString) {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    
                    self.backgroundImageView.image = UIImage(data: data)
                })
            }
        })
    }
    
}
