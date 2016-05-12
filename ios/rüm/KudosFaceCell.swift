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
    @IBOutlet weak var kudosGraphView: KudosGraphView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        if let skView = (heartSceneView as? SKView) {
            kudosButton.heartScene = heartScene
            skView.allowsTransparency = true
            skView.presentScene(heartScene)
        }
    }

    func load(member: [String: AnyObject]) {
        self.nameLabel.text = member["fullName"] as? String
        self.kudosButton.userId = member["id"] as? String
        
        activityIndicator.startAnimating()
        dispatch_async(dispatch_get_main_queue(), {
            if let urlStr = member["photo"] as? String {
                if let url = NSURL(string: urlStr) {
                    if let data = NSData(contentsOfURL: url) {
                        NSOperationQueue.mainQueue().addOperationWithBlock({
                            self.kudosButton.image = UIImage(data: data)
                            self.activityIndicator.stopAnimating()
                        })
                    } else {
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                }
            } else {
                self.activityIndicator.stopAnimating()
            }
        })
    }
    
    func clearImage() {
        self.kudosButton.image = nil
    }
    
}

class KudosGraphView: UIView {
    
    var trackLayer: CAShapeLayer?
    var graphLayer: CAShapeLayer?
    
    var val: CGFloat = 0
    
    var color: UIColor? {
        didSet {
            if self.graphLayer != nil {
                self.graphLayer!.strokeColor = color!.CGColor
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        self.trackLayer = CAShapeLayer()
        self.graphLayer = CAShapeLayer()
        
        let lineWidth: CGFloat = 6.0
        // subtract lineWidth/2 so border gets drawn inside
        let radius = self.frame.width/2.0 - lineWidth/2.0
        
        let graphFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        let graphPosition = CGPoint(x: radius + lineWidth/2, y: radius + lineWidth/2)
        
        
        let backgroundPath = UIBezierPath(arcCenter: self.center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        let graphPath = UIBezierPath(arcCenter: self.center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
        
        self.trackLayer!.fillColor = UIColor.clearColor().CGColor
        self.trackLayer!.path = backgroundPath.CGPath
        self.trackLayer!.lineWidth = lineWidth
        self.trackLayer!.strokeStart = 0.0
        self.trackLayer!.strokeEnd = 1.0
        self.trackLayer!.frame = graphFrame
        self.trackLayer!.position = graphPosition
        self.trackLayer!.fillColor = UIColor.clearColor().CGColor
        self.trackLayer!.strokeColor = UIColor.rumGrey().CGColor
        self.trackLayer!.zPosition = 0
        self.layer.addSublayer(self.trackLayer!)
        
        
        self.graphLayer!.fillColor = UIColor.clearColor().CGColor
        self.graphLayer!.path = graphPath.CGPath
        self.graphLayer!.lineWidth = lineWidth
        self.graphLayer!.strokeStart = 0.0
        self.graphLayer!.strokeEnd = 0.0
        self.graphLayer!.frame = graphFrame
        self.graphLayer!.position = graphPosition
        self.graphLayer!.fillColor = UIColor.clearColor().CGColor
        self.graphLayer!.strokeColor = UIColor.appBlue().CGColor
        self.graphLayer!.zPosition = 1
        self.layer.addSublayer(self.graphLayer!)
    }
    
    func setValue(value: CGFloat, duration: Double, delay: Double) {
        let proportion:CGFloat = max(0, value)
        
        if self.graphLayer != nil {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.duration = duration
            anim.timingFunction = CAMediaTimingFunction(controlPoints: 0.68, -0.55, 0.27, 1.55)
            self.graphLayer!.strokeEnd = proportion
            self.graphLayer!.addAnimation(anim, forKey: "animateGraph")
        }
    }
}