//
//  Constants.swift
//  TodoApp
//
//  Created by sergey on 20.12.2020.
//

import Foundation
import UIKit
enum Constants {
    // MARK: UI
    static let navigationTitleFontSize: CGFloat = UIScreen.main.bounds.height > 750 ? 22 : 18
    static let vcMinBottomPadding: CGFloat = max(30, safeAreaInsets.bottom)
//    static let vcBottomPadding2: CGFloat = max(30, safeAreaInsets.bottom)
    // Animation timings
    static let animationDefaultDuration: TimeInterval = 0.35
    
    // MARK: Model restrictions
    static let maximumProjectNameLength = 50
    static let maximumDescriptionLength = 140
    
    static let inboxId = "Inbox-inbox" // Should never be changed if migration has not been done
}

fileprivate var safeAreaInsets: UIEdgeInsets {
    guard let window = UIApplication.shared.windows.first else { return .zero }
    return window.safeAreaInsets
}
