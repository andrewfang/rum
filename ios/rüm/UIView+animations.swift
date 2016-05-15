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
            startTransform: t,
            endTransform: CGAffineTransformIdentity,
            alpha: true,
            startAlpha: nil,
            endAlpha: nil,
            completion: nil)
    }
    
    func fallOut(duration: Double, delay: Double) {
        self.fallOut(duration, delay: delay, completion: nil)
    }
    
    func fallOut(duration: Double, delay: Double, completion: ((Bool) -> Void)?) {
        let t = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, 40), CGFloat(M_PI/32))
        self.bounceTransform(duration,
            delay: delay,
            springDamping: 1,
            springVelocity: 0,
            startTransform: CGAffineTransformIdentity,
            endTransform: t,
            alpha: true,
            startAlpha: 1.0,
            endAlpha: 0,
            completion: completion)
    }
    
    func bounceSlideUpIn(duration: Double, delay: Double) {
        let t = CGAffineTransformMakeTranslation(0, 20)
        self.bounceTransform(duration,
            delay: delay,
            springDamping: 0.9,
            springVelocity: 0.2,
            startTransform: t,
            endTransform: CGAffineTransformIdentity,
            alpha: true,
            startAlpha: nil,
            endAlpha: nil,
            completion: nil)
    }
    
    func bounceTransform(duration: Double, delay: Double, springDamping: CGFloat, springVelocity: CGFloat, startTransform: CGAffineTransform, endTransform: CGAffineTransform, alpha: Bool, startAlpha: CGFloat?, endAlpha: CGFloat?, completion: ((Bool) -> Void)?) {
        
        self.transform = CGAffineTransformConcat(self.transform, startTransform)
        if alpha {
            
            if startAlpha != nil {
                self.alpha = startAlpha!
            }
            // if we happen to be in the middle of animating the alpha,
            // just let it go
            else if self.alpha == 1 {
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
                    if endAlpha != nil {
                        self.alpha = endAlpha!
                    } else {
                        self.alpha = 1
                    }
                }
                self.transform = endTransform
            }, completion: completion)
    }
}
