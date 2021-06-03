//
//  UIFont+Additions.swift
//  Cookery
//
//  Created by Nikolay Andonov on 16.05.21.
//

import UIKit

extension UIFont {
    static func applicationRegularFont(withSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func applicationSemiBoldFont(withSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    static func applicationBoldFont(withSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    static let primaryTitleFont = UIFont.applicationSemiBoldFont(withSize: 17)
    static let secondaryTitleFont = UIFont.applicationRegularFont(withSize: 14)
    static let secondaryHighlightedTitleFont = UIFont.applicationSemiBoldFont(withSize: 14)
    static let descriptionFont = UIFont.applicationRegularFont(withSize: 12)
}
