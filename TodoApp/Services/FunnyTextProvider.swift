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
        if UserDefaultsWrapper.shared.lastTimeGeneratedFunText.difference(in: .hour, from: Date()).flatMap({ $0 >= 2 }) ?? true {
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
        "Сбежать с Таркова",
        "Поиграть с Русланом в Тарков",
        "Выпустить первый релиз тудушки"
    ]
}

