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
        case id, tags, date, subtask, isDone, taskDescription, createdAt
    }
}

extension RlmTask: CascadeDeleting {
    func hardCascadeDeleteProperties() -> [String] {
        [Property.date.rawValue, Property.subtask.rawValue]
    }
}

extension RlmTask {
    static func compare(task1: RlmTask, task2: RlmTask, sorting: ProjectSorting) -> Bool {
        if !task1.isDone && task2.isDone { return true }
        if task1.isDone && !task2.isDone { return false}
        switch sorting {
        case .byCreatedAt:
            return task1.createdAt > task2.createdAt
        case .byName:
            return task1.name != task2.name ?
            task1.name > task2.name :
            task1.createdAt > task2.createdAt
        case .byPriority:
            return task1.priority != task2.priority ?
            task1.priority > task2.priority :
            task1.createdAt > task2.createdAt
        case .byDate:
            if task1.date?.date != nil && task2.date?.date != nil {
                return task1.date!.date! > task2.date!.date!
            }
            return task1.createdAt > task2.createdAt
        }
    }
}

extension RlmTask {
    func setIsDone(isDone: Bool) {
        self.isDone = isDone
        if self.date?.repeat == nil {
            RealmStore.main.updateDateDependencies(in: self)
        } else if let date = self.date, date.date != nil, isDone {
            Notifications.shared.removeNotifications(id: self.id)
            let newDate = RlmTaskDate(date: date.repeat!.addDate(initialDate: date.date!), reminder: date.reminder, repeat: date.repeat)
            let newTask = RlmTask(name: self.name, taskDescription: self.taskDescription, priority: self.priority, isDone: false, date: newDate, createdAt: Date())
            newTask.tags.append(objectsIn: tags)
            let subtasks = subtask.map { $0.name }.map { RlmSubtask(name: $0) }
            newTask.subtask.insert(contentsOf: subtasks, at: 0)
            project.first?.tasks.append(newTask)
            RealmStore.main.updateDateDependencies(in: newTask)
            realm?.delete(date)
        }
        
    }
}
