//
//  SettingsTableViewCell.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/13/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    var showArrow = false {
        didSet {
            if self.forwardArrowImageView != nil {
                self.forwardArrowImageView.hidden = !showArrow
            }
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var forwardArrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.forwardArrowImageView.hidden = !self.showArrow
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
