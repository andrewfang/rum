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
    var navTitle:String?
    
    var rightBarButtonItemText: String?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (labelText != nil) {
            label.text = labelText
        }
        
        if (self.navTitle != nil) {
            self.navigationItem.title = navTitle!
        }
        
        if (self.rightBarButtonItemText != nil) {
            self.rightBarButtonItem.title = rightBarButtonItemText
            let font = UIFont(name: "Avenir", size: 17)
            self.rightBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font!], forState: .Normal)
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        // run handle text input delegate to clear out right bar button
        // if we need to
        self.handleTextInput(self)

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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
    }

    @IBAction func pushedRightButtonItem(sender: AnyObject) {
        // just call the delegate function to simulate a
        // done push
        textFieldShouldReturn(self.textField)
    }
    
    @IBAction func handleTextInput(sender: AnyObject) {
        if self.rightBarButtonItem == nil {
            return
        }
        
        if !self.textValid(self.textField) {
            self.rightBarButtonItem.tintColor = UIColor.rumTransparentWhite()
        } else {
            self.rightBarButtonItem.tintColor = UIColor.whiteColor()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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
        if self.textValid(textField) {
            pressedDone = true
            textField.resignFirstResponder()
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
    
    private func textValid(textInput: UITextField?) -> Bool {
        if textField != nil {
            if let trimmed = textField.text?.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
                if trimmed.characters.count != 0 {
                    return true
                }
            }
        }
        return false
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
