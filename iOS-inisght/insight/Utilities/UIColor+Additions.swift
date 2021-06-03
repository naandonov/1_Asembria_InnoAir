//
//  UIColor+Additions.swift
//  Cookery
//
//  Created by Nikolay Andonov on 16.05.21.
//

import UIKit

extension UIColor {
    static var primaryBlue: UIColor? {
        return UIColor(hex: "#4367AF")
    }
    
    static var secondaryBlue: UIColor? {
        return UIColor(hex: "#8BC1FF")
    }
    
    static var ternaryBlue: UIColor? {
        return UIColor(hex: "#F0F2F9")
    }
    
    static var textColor: UIColor? {
        return UIColor(hex: "#83868D")
    }
    
    static var primaryGray: UIColor? {
        return UIColor(hex: "#E8E8E8")
    }
    
    static var secondaryGray: UIColor? {
        return UIColor(hex: "#F4F4F4")
    }
    
    static var ternaryGray: UIColor? {
        return UIColor(hex: "#979797")
    }
    
    static var primaryGreen: UIColor? {
        return UIColor(hex: "#7ED321")
    }
    
    // MARK: - Utilities
    
    public convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha:1)
    }
}

extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red }
    var greenValue: CGFloat{ return CIColor(color: self).green }
    var blueValue: CGFloat{ return CIColor(color: self).blue }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
}
