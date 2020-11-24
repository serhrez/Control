//
//  DateFormatter+Extensions.swift
//  TodoApp
//
//  Created by sergey on 22.11.2020.
//

import Foundation

extension DateFormatter {
    static func str(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
