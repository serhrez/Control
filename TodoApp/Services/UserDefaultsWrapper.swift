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
}

fileprivate extension String {
    static let premiumKey = "isPremiumPurchased"
}
