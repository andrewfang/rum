//
//  LastTaskCell.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/10/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit
import SpriteKit

protocol KudosButtonDelegate: class {
    func userDidBeginKudos()
    func userDidEndKudos()
}

class LastTaskCell: UITableViewCell {

    let heartScene = Hearts()
    var kudosButtonDelegate: KudosButtonDelegate? {
        didSet {
            kudosButton.delegate = kudosButtonDelegate
        }
    }
    
    var disableKudos = false {
        didSet {
            kudosButton.disabled = disableKudos
            infoLabel.text = disableKudos ?
                "When people in your group complete tasks, they'll show up here." :
                "Tap the photo and show some love!"
        }
    }
    
    @IBOutlet weak var attributionLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var heartSceneView: UIView!
    @IBOutlet weak var kudosButton: KudosButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
        
        kudosButton.layer.borderWidth = 4
        kudosButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        if let skView = (heartSceneView as? SKView) {
            kudosButton.heartScene = heartScene
            skView.allowsTransparency = true
            skView.presentScene(heartScene)
        }
    }
    
    
    // caller should make sure to enable/disable kudos themselves
    func loadTask(name:String, task:String, photo:String) {
        attributionLabel.text = "\(name) completed a task"
        attributionLabel.hidden = false
        taskLabel.text = task
        if let imageUrl = NSURL(string: photo) {
            if let data = NSData(contentsOfURL: imageUrl) {
                let image = UIImage(data: data)
                self.kudosButton.image = image
                self.backgroundImageView.image = image
            }
        }
    }
    
    // NOTE: disables kudos
    func loadEmpty() {
        taskLabel.text = "Hi there!"
        attributionLabel.hidden = true
        self.disableKudos = true
    }
}

class KudosButton: UIImageView {
    
    var heartScene: Hearts?
    var delegate: KudosButtonDelegate?
    var disabled = false
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if disabled {
            return
        }
        
        if heartScene != nil {
            heartScene!.start()
        }
        
        if delegate != nil {
            delegate!.userDidBeginKudos()
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
            delegate!.userDidEndKudos()
        }
    }
}