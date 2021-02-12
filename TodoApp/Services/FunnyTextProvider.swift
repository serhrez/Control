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
        "Call John Wick",
        "Complete Dark Souls",
        "Call Dad",
        "Call Sister",
        "Call Brother",
        "Buy Gifts for Family",
        "Buy Christmas Gifts",
        "Take a Vacation",
        "Start Watching One-Punch Man",
        "Start Watching Jo Jo's Incredible Adventure",
        "Add New Tasks ",
        "Reply to Email",
        "Go to the Post Office",
        "Invest in Bitcoin",
        "Extend Gym",
        "Read a Chapter of a Book",
        "Buy Gift for Tomorrow",
        "Learn to Play the Guitar",
        "Learn to Design",
        "Start Watching the Series Dark",
        "Start Going to The Gym",
        "Complete Cyberpunk 2077"
    ]
}

