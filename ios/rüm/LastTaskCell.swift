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
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            // always fill the view
            blurEffectView.frame = self.contentView.bounds
            blurEffectView.alpha = 0.8
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.contentView.insertSubview(blurEffectView, atIndex: 1)
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
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    var imageToShow:UIImage?
                    if let imgData = UIImage.imageDataFromTaskName(task) {
                        imageToShow = UIImage(data: imgData)
                    }
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.backgroundImageView.image = imageToShow ?? UIImage(named:"Welcome")
                    })
                }
                
            }
        }
    }
    
    // NOTE: disables kudos
    func loadEmpty() {
        if let photo = FacebookManager.sharedInstance.photo {
            self.kudosButton.image = photo
            self.backgroundImageView.image = photo
        }
        taskLabel.text = "Hi there!"
        attributionLabel.hidden = true
        self.disableKudos = true
    }
}
