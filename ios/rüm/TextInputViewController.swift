//
//  TextInputViewController.swift
//  rüm
//
//  Created by Jare Fagbemi on 5/10/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import UIKit

protocol TextInputViewControllerDelegate: class {
    func userDidInputText(text: String?)
}

class TextInputViewController: UIViewController, UITextFieldDelegate {

    var delegate: TextInputViewControllerDelegate?
    var labelText:String?
    var navTitle:String? {
        didSet {
            if self.isViewLoaded() {
                print(navTitle)
                self.navigationItem.title = navTitle!
            }
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (labelText != nil) {
            label.text = labelText
        }
        
        if (self.navTitle != nil) {
            self.navigationItem.title = navTitle!
        }

        textField.delegate = self
        
        let bottomBorder = CALayer(layer: textField.layer)
        bottomBorder.frame = CGRectMake(0.0, textField.frame.size.height-1, textField.frame.size.width, 1.0)
        bottomBorder.backgroundColor = UIColor.whiteColor().CGColor
        textField.layer.addSublayer(bottomBorder)
        
        textField.becomeFirstResponder()
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            // always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.alpha = 1.0
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.view.insertSubview(blurEffectView, atIndex: 0)
        }
    }

    @IBAction func handleClose(sender: AnyObject) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var pressedDone = false
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let trimmed = textField.text?.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            if trimmed.characters.count != 0 {
                pressedDone = true
                textField.resignFirstResponder()
            }
        }
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (self.delegate != nil) {
            self.delegate?.userDidInputText(textField.text)
        }
        if pressedDone {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
