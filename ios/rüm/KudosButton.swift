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
    func userDidEndKudos(kudosButton: KudosButton)
}

class KudosButton: UIImageView {
    
    var heartScene: Hearts?
    
    var delegate: KudosButtonDelegate?
    var disabled = false
    
    var userId: String?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if disabled {
            return
        }
        
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
        
        if heartScene != nil {
            heartScene!.stop()
        }
        
        if delegate != nil {
            delegate!.userDidEndKudos(self)
        }
    }
}
