//
//  UINavigationController+Extensions.swift
//  TodoApp
//
//  Created by sergey on 30.12.2020.
//

import Foundation
import UIKit

extension UINavigationController {
    func popViewControllers(_ count: Int, animated: Bool = true) {
        guard viewControllers.count > count else { return }
        popToViewController(viewControllers[viewControllers.count - count - 1], animated: animated)
    }
}
