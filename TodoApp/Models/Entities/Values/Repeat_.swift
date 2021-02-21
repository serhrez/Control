//
//  Repeat.swift
//  Todo
//
//  Created by sergey on 13.09.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation
import SwiftDate

enum Repeat: String, CustomStringConvertible {
    case everyDay
    case everyWeek
    case everyMonth
    case everyYear
    
    static let all: [Repeat] = [.everyDay, .everyWeek, .everyMonth, .everyYear]
    
    
    var description: String {
        switch self {
        case .everyDay:
            return "Every Day".localizable()
        case .everyWeek:
            return "Every Week".localizable()
        case .everyMonth:
            return "Every Month".localizable()
        case .everyYear:
            return "Every Year".localizable()
        }
    }
    func addDate(initialDate: Date) -> Date {
        switch self {
        case .everyDay: return initialDate + 24.hours
        case .everyWeek: return initialDate + 1.weeks
        case .everyMonth: return initialDate + 1.months
        case .everyYear: return initialDate + 1.years
        }
    }
}
