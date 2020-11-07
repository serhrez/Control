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
}

extension Reminder {
    static let allViewCases: [Reminder?] = [nil] + Reminder.all

    static var textClosure: (Reminder?) -> String = {
        switch $0 {
            case .some(.onDay):
                return "On the day"
            case .some(.oneDayEarlier):
                return "1 day early"
            case .some(.twoDaysEarlier):
                return "2 day early"
            case .some(.threeDaysEarlier):
                return "3 day early"
            case .none:
                return "None"
        }
    }
}
