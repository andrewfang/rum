//
//  QuickCompleteCollectionViewCell.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/10/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class QuickCompleteCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func loadTask(name: String) {
        label.text = name
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
            if let data = UIImage.imageDataFromTaskName(name.lowercaseString) {
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.imageView.image = UIImage(data: data)
                })
            }
        })
    }
}
