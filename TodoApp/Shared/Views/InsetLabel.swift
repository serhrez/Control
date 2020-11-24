//
//  InsetLabel.swift
//  TodoApp
//
//  Created by sergey on 19.11.2020.
//

import Foundation
import UIKit

class InsetLabel: UILabel {
    var insets = UIEdgeInsets.zero

    override var intrinsicContentSize:CGSize {
        var s = super.intrinsicContentSize
        s.height = s.height + insets.top + insets.bottom
        s.width = s.width + insets.left + insets.right
        return s
    }

    override func drawText(in rect:CGRect) {
        let r = rect.inset(by: insets)
        super.drawText(in: r)
    }

    override func textRect(forBounds bounds:CGRect,
                               limitedToNumberOfLines n:Int) -> CGRect {
        return super.textRect(forBounds: bounds.inset(by: insets), limitedToNumberOfLines: numberOfLines)
    }
}
