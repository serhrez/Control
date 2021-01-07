//
//  Task.swift
//  Todo
//
//  Created by sergey on 11.06.2020.
//  Copyright © 2020 com.SergeyReznichenko. All rights reserved.
//

import Foundation
import RealmSwift

final class RlmTask: Object, Identifiable {
    @objc dynamic var id = UUID().uuidString
    let tags = List<RlmTag>()
    @objc dynamic var date: RlmTaskDate?
    let subtask = List<RlmSubtask>()
    @objc dynamic var isDone = false
    @objc dynamic var name = ""
    @objc dynamic var taskDescription = ""
    @objc dynamic var createdAt = Date()
    let project = LinkingObjects(fromType: RlmProject.self, property: "tasks")
    
    @objc dynamic private var _priority = ""
    var priority: Priority {
        get { Priority(rawValue: _priority) ?? .none }
        set { _priority = newValue.rawValue}
    }
    
    override static func primaryKey() -> String? {
        RlmTask.Property.id.rawValue
    }
    
    convenience init(name: String, taskDescription: String = "", priority: Priority, isDone: Bool, date: RlmTaskDate? = nil, createdAt: Date = Date()) {
        self.init()
        self.name = name
        self.taskDescription = taskDescription
        self.date = date
        self.priority = priority
        self.isDone = isDone
        self.createdAt = createdAt
    }
}

extension RlmTask {
    enum Property: String {
        case id, tag, date, isDone, taskDescription, createdAt
    }
}
