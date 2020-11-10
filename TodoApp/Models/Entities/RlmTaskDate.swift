//
//  TaskDate.swift
//  Todo
//
//  Created by sergey on 11.06.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation
import RealmSwift

final class RlmTaskDate: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var date: Date? = Date() // TODO: shouldn't be forced
    @objc dynamic private var _reminder: String?
    var reminder: Reminder? {
        get { _reminder.flatMap { Reminder(rawValue: $0) } }
        set { _reminder = newValue?.rawValue }
    }
    @objc dynamic private var _repeat: String?
    var `repeat`: Repeat? {
        get { _repeat.flatMap { Repeat(rawValue: $0) } }
        set { _repeat = newValue?.rawValue }
    }
    
    convenience init(date: Date?, reminder: Reminder?, repeat: Repeat?) {
        self.init()
        self.date = date ?? Date()
        self.reminder = reminder
        self.repeat = `repeat`
    }
    
    // TODO: Add this, and update bundled realm
//    override class func primaryKey() -> String? {
//        Tag.TaskDate.id.rawValue
//    }
}

extension RlmTag {
    enum TaskDate: String {
        case id, date, _reminder, _repeat
    }
}
