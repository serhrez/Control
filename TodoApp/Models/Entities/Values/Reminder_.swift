//
//  Reminder.swift
//  Todo
//
//  Created by sergey on 13.09.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation

enum Reminder: String, CustomStringConvertible {
    case oneDayEarly
    case fiveMinutesBefore
    case tenMinutesBefore
    case thirtyMinutesBefore
    case oneHourBefore
    case twoHoursBefore
    case oneWeekBefore
    
    static let all: [Reminder] = [.oneDayEarly, .fiveMinutesBefore, .tenMinutesBefore, .thirtyMinutesBefore, .oneHourBefore, .twoHoursBefore, .oneWeekBefore]
    
    var description: String {
        switch self {
        case .oneDayEarly: return "One Day Earlier".localizable()
        case .fiveMinutesBefore: return "5 Minutes Before".localizable()
        case .tenMinutesBefore: return "10 Minutes Before".localizable()
        case .thirtyMinutesBefore: return "30 Minutes Before".localizable()
        case .oneHourBefore: return "1 Hour Before".localizable()
        case .twoHoursBefore: return "2 Hour Before".localizable()
        case .oneWeekBefore: return "One Week Before".localizable()
        }
    }
}

