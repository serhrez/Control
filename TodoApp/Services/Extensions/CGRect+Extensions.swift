//
//  CGRect+Extensions.swift
//  TodoApp
//
//  Created by sergey on 01.01.2021.
//

import Foundation
import UIKit

extension CGRect {
    func modify(modifyX: (CGFloat) -> CGFloat = { $0 },
                modifyY: (CGFloat) -> CGFloat = { $0 },
                modifyWidth: (CGFloat) -> CGFloat = { $0 },
                modifyHeight: (CGFloat) -> CGFloat = { $0 }) -> CGRect {
        return .init(x: modifyX(minX), y: modifyY(minY), width: modifyWidth(width), height: modifyHeight(height))
    }
}
