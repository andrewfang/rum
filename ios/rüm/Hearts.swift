//
//  Hearts.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/11/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import Foundation
import SpriteKit

class Hearts : SKScene {
    var emitter: SKEmitterNode?
    
    override func didMoveToView(view: SKView) {
        self.scaleMode = .ResizeFill
        backgroundColor = UIColor.clearColor()
    }
    
    func start() {
        emitter = SKEmitterNode(fileNamed: "HeartsParticle.sks")
        if emitter != nil {
            emitter!.particleBirthRate = 4.0
            let x: CGFloat = floor(self.size.width / 2.0)
            let y: CGFloat = 30.0
            emitter!.position = CGPointMake(x, y)
            
            emitter!.particleColorSequence = nil
            emitter!.particleColorBlendFactor = 1.0
            
            emitter!.name = "hearts"
            emitter!.targetNode = self
            
            self.addChild(emitter!)
            
            let action = SKAction.runBlock({
                let colors = UIColor.heartColors()
                let rand = Int(arc4random_uniform((UInt32(colors.count))))
                self.emitter!.particleColor = colors[rand]
                
            })
            let wait = SKAction.waitForDuration(0.2)
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([action, wait])))
        }
    }
    
    func stop() {
        if emitter != nil {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.4 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), {
                self.emitter!.particleBirthRate = 0.0
            })
        }
    }
}