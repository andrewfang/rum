//
//  ActionButton.swift
//  bucketsO
//
//  Created by Andrew Fang on 2/10/16.
//  Copyright © 2016 Alisha Adam. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    
    override func drawRect(rect: CGRect) {
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        
        // Title Attributes
        self.titleLabel?.font = UIFont(name: "Avenir", size: 17.0)
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        // Border
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1.2
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.backgroundColor = UIColor.clearColor().CGColor
        
        self.addTarget(self, action: #selector(ActionButton.tapped), forControlEvents: .TouchDown)
        self.addTarget(self, action: #selector(ActionButton.untapped), forControlEvents: .TouchUpInside)
        self.addTarget(self, action: #selector(ActionButton.untapped), forControlEvents: .TouchDragOutside)
    }
    
    override func intrinsicContentSize() -> CGSize {
        let size = super.intrinsicContentSize()
        return CGSizeMake(size.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
            size.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom)
    }
    
    func tapped() {
        self.alpha = 0.5
    }
    
    func untapped() {
        self.alpha = 1.0
    }

    
}
