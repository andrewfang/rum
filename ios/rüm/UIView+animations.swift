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
        self.bounceIn(duration, delay: 0.2)
    }
    
    func bounceIn(duration: Double, delay: Double) {
        let t = CGAffineTransformMakeScale(0.4, 0.4)
        self.bounceTransform(duration,
            delay: delay,
            springDamping: 0.5,
            springVelocity: 0.2,
            transform: t,
            alpha: true)
    }
    
    func bounceSlideUpIn(duration: Double, delay: Double) {
        let t = CGAffineTransformMakeTranslation(0, 20)
        self.bounceTransform(duration,
            delay: delay,
            springDamping: 0.9,
            springVelocity: 0.2,
            transform: t,
            alpha: true)
    }
    
    func bounceTransform(duration: Double, delay: Double, springDamping: CGFloat, springVelocity: CGFloat, transform: CGAffineTransform, alpha: Bool) {
        
        self.transform = CGAffineTransformConcat(self.transform, transform)
        if alpha {
            // if we happen to be in the middle of animating the alpha,
            // just let it go
            if self.alpha == 1 {
                self.alpha = 0
            }
        }
        
        UIView.animateWithDuration(duration,
            delay: delay,
            usingSpringWithDamping: springDamping,
            initialSpringVelocity: springVelocity,
            options: [],
            animations: {
                if alpha {
                    self.alpha = 1
                }
                self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
}
