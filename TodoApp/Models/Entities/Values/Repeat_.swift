//
//  Repeat.swift
//  Todo
//
//  Created by sergey on 13.09.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation

enum Repeat: String {
    case daily
    case everyWeekday
    case weekly
    case monthly
    case yearly
    
    
    var description: String {
        switch self {
        case .daily:
            return "Daily"
        case .everyWeekday:
            return "Every Weekday"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }
}
