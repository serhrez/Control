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
    init() {
        defaults.register(defaults: [
            .isPremium: false,
            .didOnboard: false,
            .debugDeleteDb: true,
            .lastTimeGeneratedFunTextNumber: -1
        ])
    }
    var isPremium: Bool {
        get { defaults.bool(forKey: .isPremium) }
        set { defaults.setValue(newValue, forKey: .isPremium) }
    }
    
    var didOnboard: Bool {
        get { defaults.bool(forKey: .didOnboard) }
        set { defaults.setValue(newValue, forKey: .didOnboard) }
    }
    
    var debugDeleteDb: Bool {
        get { defaults.bool(forKey: .debugDeleteDb) }
        set { defaults.setValue(newValue, forKey: .debugDeleteDb) }
    }
    var lastTimeGeneratedFunText: Date {
        get { defaults.value(forKey: .lastTimeGeneratedFunText) as? Date ?? .distantPast }
        set { defaults.setValue(newValue, forKey: .lastTimeGeneratedFunText) }
    }
    var lastTimeGeneratedFunTextNumber: Int {
        get { defaults.integer(forKey: .lastTimeGeneratedFunTextNumber) }
        set { defaults.setValue(newValue, forKey: .lastTimeGeneratedFunTextNumber) }
    }
}

fileprivate extension String {
    static let isPremium = "isPremiumPurchased"
    static let didOnboard = "didOnboard"
    static let debugDeleteDb = "debugDeleteDb"
    static let lastTimeGeneratedFunText = "lastTimeGeneratedFunText"
    static let lastTimeGeneratedFunTextNumber = "lastTimeGeneratedFunTextNumber"
}
