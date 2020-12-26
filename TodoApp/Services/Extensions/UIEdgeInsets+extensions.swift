//
//  UIEdgeInsets+extensions.swift
//  TodoApp
//
//  Created by sergey on 27.12.2020.
//

import Foundation
import UIKit

extension UIEdgeInsets {
    func inverted() -> UIEdgeInsets {
        .init(top: -self.top, left: -self.left, bottom: -self.bottom, right: -self.right)
    }
}
