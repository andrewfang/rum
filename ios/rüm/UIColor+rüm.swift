//
//  UIColor+IoART.swift
//  IoART
//
//  All the colors we're using
//
//  Created by Andrew Fang on 4/19/16.
//  Copyright © 2016 Fang Industries. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    static func appRed() -> UIColor { return UIColor.rgb(249, 30, 55) }
    static func appOrange() -> UIColor { return UIColor.rgb(255, 104, 17) }
    static func appYellow() -> UIColor { return UIColor.rgb(251, 178, 38) }
    static func appTeal() -> UIColor { return UIColor.rgb(52, 178, 188) }
    static func appBlue() -> UIColor { return UIColor.rgb(82, 132, 195) }
    static func appPurple() -> UIColor { return UIColor.rgb(204, 127, 174) }
    
    // Given a r,g,b, transforms it into a UIColor element
    static func rgb(red:CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor{
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
}