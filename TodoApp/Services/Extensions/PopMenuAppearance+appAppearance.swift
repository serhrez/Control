//
//  PopMenuAppearance+appAppearance.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import UIKit
import PopMenu

extension PopMenuAppearance {
    static let appAppearance: PopMenuAppearance = {
        let appearance = PopMenuAppearance()
        appearance.popMenuCornerRadius = 16
        appearance.popMenuColor.actionColor = .tint(.black)
        appearance.popMenuColor.backgroundColor = .solid(fill: UIColor(named: "TAAltBackground")!)
        appearance.popMenuFont = .systemFont(ofSize: 17, weight: .semibold)
        appearance.popMenuItemSeparator = .fill(UIColor(red: 0.875, green: 0.875, blue: 0.875, alpha: 1), height: 1)
        appearance.popMenuActionHeight = 47
        appearance.actionsSpacing = 10
        appearance.popMenuColor.actionColor = .tint(.black)
        appearance.popMenuColor.selectionColor = .tint(UIColor(named: "TASubElement")!)
        appearance.popMenuBackgroundStyle = .dimmed(color: UIColor(red: 0.965, green: 0.965, blue: 0.953, alpha: 1), opacity: 0.5)
        appearance.popMenuPadding = .init(top: 12, left: 10, bottom: 12, right: 10)
        appearance.popMenuActionCountForScrollable = 12
        
        return appearance
    }()
    
    static func appCustomizeActions(actions: [PopuptodoAction]) {
        actions.forEach {
            $0.iconWidthHeight = 20
        }
    }
}

