//
//  LastTaskCell.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/10/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit
import SpriteKit

class LastTaskCell: UITableViewCell {

    let heartScene = Hearts()
    
    @IBOutlet weak var attributionLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var heartSceneView: UIView!
    @IBOutlet weak var kudosButton: KudosButton!
    
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
    
    
    func loadTask(name:String, task:String, photo:String) {
        attributionLabel.text = "\(name) completed a task"
        taskLabel.text = task
        if let imageUrl = NSURL(string: photo) {
            if let data = NSData(contentsOfURL: imageUrl) {
                let image = UIImage(data: data)
                self.kudosButton.image = image
                self.backgroundImageView.image = image
            }
        }
    }
}

class KudosButton: UIImageView {
    
    var heartScene: Hearts?
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touching")
        if heartScene != nil {
            heartScene!.start()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("not touching")
        if heartScene != nil {
            heartScene!.stop()
        }
    }
}