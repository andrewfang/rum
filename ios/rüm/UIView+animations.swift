//
//  UIView+animations.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/11/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func bounceIn(duration: Double) {
        self.transform = CGAffineTransformMakeScale(0.4, 0.4)
    
        UIView.animateWithDuration(duration,
            delay: 0.2,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.2,
            options: [],
            animations: {
                self.transform = CGAffineTransformMakeScale(1, 1)
            }, completion: nil)
    }
}
