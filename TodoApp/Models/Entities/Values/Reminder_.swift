//
//  Reminder.swift
//  Todo
//
//  Created by sergey on 13.09.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation

enum Reminder: String {
    case onDay
    case oneDayEarlier
    case twoDaysEarlier
    case threeDaysEarlier
    
    static let all: [Reminder] = [.onDay, .oneDayEarlier, .twoDaysEarlier, .threeDaysEarlier]
    
    var description: String {
        switch self {
            case .onDay:
                return "On the day"
            case .oneDayEarlier:
                return "1 day early"
            case .twoDaysEarlier:
                return "2 day early"
            case .threeDaysEarlier:
                return "3 day early"
        }
    }
}

