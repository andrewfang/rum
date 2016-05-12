//
//  KudosButton.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/12/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

protocol KudosButtonDelegate: class {
    func userDidBeginKudos(kudosButton: KudosButton)
    func userDidEndKudos(kudosButton: KudosButton, numKudos: Int)
}

class KudosButton: UIImageView {
    
    var heartScene: Hearts?
    
    var delegate: KudosButtonDelegate?
    var disabled = false
    var startTime: Double = 0.0
    
    var userId: String?
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if disabled {
            return
        }
        
        self.startTime = NSDate().timeIntervalSince1970
        if heartScene != nil {
            heartScene!.start()
        }
        
        if delegate != nil {
            delegate!.userDidBeginKudos(self)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if disabled {
            return
        }
        
        let total = NSDate().timeIntervalSince1970 - self.startTime
        
        if heartScene != nil {
            heartScene!.stop()
        }
        
        if delegate != nil {
            // give kudos at a rate of 4 per second, + 1 to ensure that we
            // give at least 1
            let numKudos = Int(floor(total * 4) + 1)
            delegate!.userDidEndKudos(self, numKudos: numKudos)
        }
    }
}
