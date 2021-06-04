//
//  UIViewController+Factory.swift
//  insight
//
//  Created by Nikolay Andonov on 2.06.21.
//

import UIKit

private enum Storyboard: String {
    case main = "Main"
}

extension UIViewController {
    static var containmentNavigationController: UINavigationController {
        return UIStoryboard(name: Storyboard.main.rawValue, bundle: nil).instantiateViewController(identifier: "ContainmentNavigationController")
    }
    
    static var routeDetailsViewController: RouteDetailsViewController {
        return UIStoryboard(name: Storyboard.main.rawValue, bundle: nil).instantiateViewController(identifier: "RouteDetailsViewController")
    }
    
    static var successViewController: SuccessViewController {
        return UIStoryboard(name: Storyboard.main.rawValue, bundle: nil).instantiateViewController(identifier: "SuccessViewController")
    }
}
