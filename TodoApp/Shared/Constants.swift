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
    static var navigationTitleFontSize: CGFloat = UIScreen.main.bounds.height > 750 ? 22 : 18
    static var vcMinBottomPadding: CGFloat = max(30, safeAreaInsets.bottom)
//    static let vcBottomPadding2: CGFloat = max(30, safeAreaInsets.bottom)
    // Animation timings
    static var animationDefaultDuration: TimeInterval = 0.18
    static var animationBottomMessagesDuration: TimeInterval = 0.5
    static var topInsetSpacingBetweenSearchBarAndElements: CGFloat = 20
    static let displayVersion2: Bool = UIScreen.main.bounds.width < 400
    
    // MARK: Model restrictions
    
    static let inboxId = "Inbox-inbox" // Should never be changed if migration has not been done
    // MARK: Premium
    static let maximumTasksCount = 40
    static let archiveWithoutPremium = false
    static let maximumDatesToTask = 4
}

fileprivate var safeAreaInsets: UIEdgeInsets {
    guard let window = UIApplication.shared.windows.first else { return .zero }
    return window.safeAreaInsets
}
