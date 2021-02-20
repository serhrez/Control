//
//  FunnyTextProvider.swift
//  TodoApp
//
//  Created by sergey on 08.02.2021.
//

import Foundation
import SwiftDate

class FunnyTextProvider {
    static let shared = FunnyTextProvider()
    private init() {
        
    }
    
    func getFunText() -> String {
        if UserDefaultsWrapper.shared.lastTimeGeneratedFunText.difference(in: .minute, from: Date()).flatMap({ $0 >= 1 }) ?? true {
            updateTextCounter()
        }
        return FunnyTextProvider.phrases[safe: UserDefaultsWrapper.shared.lastTimeGeneratedFunTextNumber] ?? FunnyTextProvider.phrases[safe: 0] ?? "New To-Do"
    }
    
    private func updateTextCounter() {
        UserDefaultsWrapper.shared.lastTimeGeneratedFunText = Date()
        let currentIndex = UserDefaultsWrapper.shared.lastTimeGeneratedFunTextNumber
        let newIndex = currentIndex + 1
        if FunnyTextProvider.phrases.indices.contains(newIndex) {
            UserDefaultsWrapper.shared.lastTimeGeneratedFunTextNumber = newIndex
        } else {
            UserDefaultsWrapper.shared.lastTimeGeneratedFunTextNumber = 0
        }
    }
}

extension FunnyTextProvider {
    static let phrases: [String] = [
        "Call John Wick".localizable(),
        "Complete Dark Souls".localizable(),
        "Call Dad".localizable(),
        "Call Sister".localizable(),
        "Call Brother".localizable(),
        "Buy Gifts for Family".localizable(),
        "Buy Christmas Gifts".localizable(),
        "Take a Vacation".localizable(),
        "Start Watching One-Punch Man".localizable(),
        "Start Watching Jo Jo's Incredible Adventure".localizable(),
        "Add New Tasks".localizable(),
        "Reply to Email".localizable(),
        "Go to the Post Office".localizable(),
        "Invest in Bitcoin".localizable(),
        "Extend Gym".localizable(),
        "Read a Chapter of a Book".localizable(),
        "Buy Gift for Tomorrow".localizable(),
        "Learn to Play the Guitar".localizable(),
        "Learn to Design".localizable(),
        "Start Watching the Series Dark".localizable(),
        "Start Going to The Gym".localizable(),
        "Complete Cyberpunk 2077".localizable()
    ]
}

