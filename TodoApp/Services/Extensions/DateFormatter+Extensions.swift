//
//  DateFormatter+Extensions.swift
//  TodoApp
//
//  Created by sergey on 22.11.2020.
//

import Foundation
import SwiftDate
extension DateFormatter {
    fileprivate static let formatter = DateFormatter()
    static func str(from date: Date) -> String {
        if date.isToday {
            formatter.dateFormat = "HH:mm"
            return "Today " + formatter.string(from: date)
        } else if date.isTomorrow {
            formatter.dateFormat = "HH:mm"
            return "Tomorrow " + formatter.string(from: date)
        } else if date.isInside(date: Date(), granularity: .weekOfYear) {
            formatter.dateFormat = "EEEE, HH:mm"
            return formatter.string(from: date)
        } else if date.isInside(date: Date().dateAt(.nextWeek), granularity: .weekOfYear) {
            formatter.dateFormat = "E, d MMM HH:mm"
            return formatter.string(from: date)
        } else {
            formatter.dateFormat = "d MMM yyyy, HH:mm"
            return formatter.string(from: date)
        }
    }
}
