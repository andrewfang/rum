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
    
    static func rumTransparentWhite() -> UIColor { return UIColor.rgba(255, 255, 255, 0.48) }
    static func rumGrey() -> UIColor { return UIColor.rgb(239, 239, 239) }
    static func rumBlue() -> UIColor { return UIColor.rgb(59, 167, 255) }
    static func rumTeal() -> UIColor { return UIColor.rgb(21, 191, 197) }
    static func rumGold() -> UIColor { return UIColor.rgb(255, 212, 82) }
    static func rumMagenta() -> UIColor { return UIColor.rgb(254, 62, 128) }
    static func rumBlack() -> UIColor { return UIColor.rgb(25, 25, 25) }
    
    static func rumGraphColors() -> [UIColor] {
        return [rumBlue(), rumTeal(), rumGold(), rumMagenta()]
    }
    
    static func heartColors() -> [UIColor] {
        return [
            UIColor.rgb(255, 192, 203),
            UIColor.rgb(186, 29, 29),
            UIColor.rgb(255, 213, 192),
            UIColor.rgb(255, 255, 255)
        ]
    }
    
    // Given a r,g,b, transforms it into a UIColor element
    static func rgb(red:CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor{
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    // Given a r,g,b, transforms it into a UIColor element
    static func rgba(red:CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor{
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
