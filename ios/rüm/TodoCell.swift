//
//  TodoCell.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/10/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

protocol TodoCellDelegate {
    func userDidCompleteTodo(todoCell: TodoCell)
    func userDidDeleteTodo(todoCell: TodoCell)
}

class TodoCell: UITableViewCell {

    var taskId: String?
    var originalCenter: CGPoint?
    var delegate: TodoCellDelegate?
    var shouldComplete = false
    var shouldDelete = false
    
    @IBOutlet weak var deleteBackground: UIView!
    @IBOutlet weak var completeBackground: UIView!
    @IBOutlet weak var deleteBackgroundIcon: UIImageView!
    @IBOutlet weak var completeBackgroundIcon: UIImageView!
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var repetitionLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var assignedToImageView: UIImageView!
    @IBOutlet weak var swipeableView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let recognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan))
        recognizer.delegate = self
        swipeableView.addGestureRecognizer(recognizer)
        
        self.selectionStyle = .None
        
        deleteBackground.alpha = 0
        completeBackground.alpha = 1
    }

    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            originalCenter = self.swipeableView.center
            
            // start by showing complete background
            deleteBackground.alpha = 0
            completeBackground.alpha = 1
            
            // bounce in icons -- each is hidden by their parent,
            // so only the proper one will actually show
            completeBackgroundIcon.bounceIn(0.8)
            deleteBackgroundIcon.bounceIn(0.8)
        }
        
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            self.swipeableView.center = CGPointMake(originalCenter!.x + translation.x, originalCenter!.y)
            
            // if moving left, show delete background
            // otherwise, show complete background
            if translation.x < 0 {
                deleteBackground.alpha = 1
                completeBackground.alpha = 0
            } else {
                deleteBackground.alpha = 0
                completeBackground.alpha = 1
            }
            
            // should complete if the user swipes more than halfway to
            // the right screen
            shouldComplete = self.swipeableView.frame.origin.x > (self.swipeableView.frame.size.width / 2)
            
            // should delete if the user swipes more than halfway to
            // the left of the screen
            shouldDelete = self.swipeableView.frame.origin.x < (-self.swipeableView.frame.size.width / 2)
            
        }
        
        if recognizer.state == .Ended {
            if shouldComplete {
                if (delegate != nil) {
                    delegate!.userDidCompleteTodo(self)
                }
            } else if shouldDelete {
                if (delegate != nil) {
                    delegate!.userDidDeleteTodo(self)
                }
            } else {
                // if no action, then snap back to the original frame
                let originalFrame = CGRect(x: 0, y: swipeableView.frame.origin.y, width: swipeableView.bounds.size.width, height: swipeableView.bounds.size.height)
                UIView.animateWithDuration(0.6,
                    delay: 0,
                    usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0.5,
                    options: [],
                    animations: {
                        self.swipeableView.frame = originalFrame
                    }, completion: nil)
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        // determine whether the pan is more vertical or horizontal
        // if it's more positive, ignore it so that scrolling doesn't
        // get messed with
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            return fabs(translation.x) > fabs(translation.y)
        }
        return false
    }
    
    func loadTask(id: String?, title: String?, assignedTo: [String : AnyObject]?) {
        self.taskId = id
        self.taskLabel.text = title
        if (assignedTo != nil) {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), {
                if let urlStr = assignedTo!["photo"] as? String {
                    if let url = NSURL(string: urlStr) {
                        if let data = NSData(contentsOfURL: url) {
                            NSOperationQueue.mainQueue().addOperationWithBlock({
                                self.assignedToImageView.image = UIImage(data: data)
                            })
                        }
                    }
                }
            })
        } else {
            assignedToImageView.alpha = 0;
        }
    }
}
