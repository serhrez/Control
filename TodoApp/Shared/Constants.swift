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
    static var navigationTitleFontSize: CGFloat = Constants.displayVersion2 ? 18 : 22
    static var vcMinBottomPadding: CGFloat = Constants.displayVersion2 ? 10 : max(30, safeAreaInsets.bottom)
//    static let vcBottomPadding2: CGFloat = max(30, safeAreaInsets.bottom)
    // Animation timings
    static var animationDefaultDuration: TimeInterval = 0.18
    static var animationBottomMessagesDuration: TimeInterval = 0.5
    static var topInsetSpacingBetweenSearchBarAndElements: CGFloat = 15
    static let displayVersion2: Bool = UIScreen.main.bounds.width < 400
    static let animationOnboardingDuration = 0.5
    
    // MARK: Model restrictions
    
    static let inboxId = "Inbox-inbox" // Should never be changed if migration has not been done
    // MARK: Premium
    static let archiveWithoutPremium = false
    static let maximumTags = 10
    static let maximumDatesToTask = 15
    static let maximumPriorities = 20
    
    // MARK: Misc
    static let colors: [UIColor] = [.hex("#242424"), .hex("#447BFE"), .hex("#571CFF"), .hex("#00CE15"), .hex("#FFE600"), .hex("#EF4439"), .hex("#FF9900")]
    static let colorsForRandom: [UIColor] = [.hex("#447BFE"), .hex("#571CFF"), .hex("#00CE15"), .hex("#EF4439"), .hex("#FF9900")]
}

fileprivate var safeAreaInsets: UIEdgeInsets {
    guard let window = UIApplication.shared.windows.first else { return .zero }
    return window.safeAreaInsets
}
