//
//  UserDefaultsWrapper.swift
//  TodoApp
//
//  Created by sergey on 12.01.2021.
//

import Foundation

class UserDefaultsWrapper {
    private let defaults = UserDefaults.standard
    static let shared = UserDefaultsWrapper()
    
    var isPremium: Bool {
        get { defaults.bool(forKey: .premiumKey) }
        set { defaults.setValue(newValue, forKey: .premiumKey) }
    }
    
    var didOnboard: Bool {
        get { defaults.bool(forKey: .onboardKey) }
        set { defaults.setValue(newValue, forKey: .onboardKey) }
    }
}

fileprivate extension String {
    static let premiumKey = "isPremiumPurchased"
    static let onboardKey = "didOnboard"
}
