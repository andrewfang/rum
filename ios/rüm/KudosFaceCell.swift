//
//  KudosFaceCell.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/11/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit
import SpriteKit

class KudosFaceCell: UICollectionViewCell {

    var heartScene = Hearts()
    var kudosButtonDelegate:KudosButtonDelegate? {
        didSet {
            self.kudosButton.delegate = kudosButtonDelegate
        }
    }
    
    @IBOutlet weak var kudosButton: KudosButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var heartSceneView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        kudosButton.layer.borderWidth = 4
        kudosButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        if let skView = (heartSceneView as? SKView) {
            kudosButton.heartScene = heartScene
            skView.allowsTransparency = true
            skView.presentScene(heartScene)
        }
    }

    func load(member: [String: AnyObject]) {
        self.nameLabel.text = member["fullName"] as? String
        self.kudosButton.userId = member["id"] as? String
        
        dispatch_async(dispatch_get_main_queue(), {
            if let urlStr = member["photo"] as? String {
                if let url = NSURL(string: urlStr) {
                    if let data = NSData(contentsOfURL: url) {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.kudosButton.image = UIImage(data: data)
                        })
                    }
                }
            }
        })
    }
    
}
