//
//  TodoCell.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/10/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class TodoCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var repetitionLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var assignedToImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadTask(title: String?, assignedTo: [String : AnyObject]?) {
        taskLabel.text = title
        
        if (assignedTo != nil) {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
                if let urlStr = assignedTo!["photo"] as? String {
                    if let url = NSURL(string: urlStr) {
                        if let data = NSData(contentsOfURL: url) {
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.assignedToImageView.image = UIImage(data: data)
                            })
                        }
                    }
                }
            })
        } else {
            assignedToImageView.alpha = 0;
        }
    }
}
