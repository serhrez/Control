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
            .debugDeleteDb: false,
            .lastTimeGeneratedFunTextNumber: -1,
            .priorityScreenSorting: ProjectSorting.byPriority.rawValue,
            .todayScreenSorting: ProjectSorting.byDate.rawValue
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
    var priorityScreenSorting: ProjectSorting {
        get { ProjectSorting(rawValue: defaults.string(forKey: .priorityScreenSorting) ?? "") ?? ProjectSorting.byPriority }
        set { defaults.setValue(newValue.rawValue, forKey: .priorityScreenSorting) }
    }
    var todayScreenSorting: ProjectSorting {
        get { ProjectSorting(rawValue: defaults.string(forKey: .todayScreenSorting) ?? "") ?? ProjectSorting.byCreatedAt }
        set { defaults.setValue(newValue.rawValue, forKey: .todayScreenSorting) }
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
    static let priorityScreenSorting = "priorityScreenSorting"
    static let todayScreenSorting = "todayScreenSorting"
}
