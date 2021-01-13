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
    case fiveMinutesEarly
    case tenMinutesEarly
    case thirtyMinutesEarly
    
    static let all: [Reminder] = [.oneDayEarly, .fiveMinutesEarly, .tenMinutesEarly, .thirtyMinutesEarly]
    
    var description: String {
        switch self {
            case .oneDayEarly:
                return "One day earlier"
            case .fiveMinutesEarly:
                return "5 minutes early"
            case .tenMinutesEarly:
                return "10 minutes early"
            case .thirtyMinutesEarly:
                return "30 minutes early"
        }
    }
}

