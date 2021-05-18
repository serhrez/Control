//
//  Style.swift
//  TodoApp
//
//  Created by sergey on 19.05.2021.
//

import Foundation
import UIKit

enum Style {
    // MARK: - UIView
    static func sizeSpecified(width: Int, height: Int) -> (UIView) -> Void {
        return {
            $0.widthAnchor.constraint(equalToConstant: 58).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 58).isActive = true
        }
    }
    // MARK: - UITextField
    static func coloredTextField(_ font: UIFont, _ color: UIColor) -> (UITextField) -> Void {
        return {
            $0.font = font// Fonts.heading1
            $0.textColor = color// UIColor(named: "TAHeading")!
        }
    }
    // MARK: - ClickableIconView
    static func clickableIconSizeSpecified(width: Int, height: Int, icon: Icon) -> (ClickableIconView) -> Void {
        return sizeSpecified(width: width, height: height) <> {
            $0.iconView.iconFontSize = 58
            $0.iconView.configure(icon)
        }
    }
}
