//
//  ChoreTableViewCell.swift
//  rüm
//
//  Created by Andrew Fang on 5/5/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

class ChoreTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var checkbox: UIButton!

    var isChecked:Bool = false {
        didSet {
            if (isChecked) {
                self.checkbox.setImage(UIImage(named: "circleFilled"), forState: .Normal)
            } else {
                self.checkbox.setImage(UIImage(named: "circle"), forState: .Normal)
            }
        }
    }
}
