//
//  TasksProvider.swift
//  TodoApp
//
//  Created by sergey on 28.02.2021.
//

import WidgetKit
import SwiftUI
import SwiftDate

struct TasksEntry: TimelineEntry {
    let date: Date
    let tasks: [Task]
    
    struct Task {
        var priority: Priority
        var name: String
        var time: String
        var isDone: Bool
        var isAllDone: Bool = false
        var isPlaceholder: Bool = false
        
        static func allDoneTask() -> Task {
            Task(priority: .none, name: "", time: "", isDone: false, isAllDone: true)
        }
        static func placeholder() -> Task {
            Task(priority: .none, name: " ", time: "", isDone: false, isAllDone: false, isPlaceholder: true)
        }
    }
}

struct TasksProvider: TimelineProvider {
    
    func getSnapshot(in context: Context, completion: @escaping (TasksEntry) -> Void) {
        let entry = TasksEntry(date: .init(), tasks: getTasks())
        completion(entry)
    }
        
    func getTimeline(in context: Context, completion: @escaping (Timeline<TasksEntry>) -> Void) {
        let entry = TasksEntry(date: .init(), tasks: getTasks())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> TasksEntry {
        .init(date: .init(), tasks: [
                TasksEntry.Task(priority: .medium, name: "Extend Gym", time: "19:00", isDone: false),
                TasksEntry.Task(priority: .low, name: "Buy Gift for Tomorrow", time: "17:30", isDone: false),
                TasksEntry.Task(priority: .none, name: "Buy Christmas Gifts", time: "21:50", isDone: true)
                ])
    }
    
    func getTasks() -> [TasksEntry.Task] {
        let tasks = RealmProvider.main.realm.objects(RlmTask.self).filter { $0.date?.date?.isToday ?? false }.sorted(by: { $0.date!.date! < $1.date!.date! }).map {
            TasksEntry.Task(priority: $0.priority, name: $0.name, time: $0.date!.date!.toFormat("HH:mm"), isDone: $0.isDone)
        }
        
        return sortedByIsDone(Array(tasks))
    }
}

fileprivate func sortedByIsDone(_ array: [TasksEntry.Task]) -> [TasksEntry.Task] {
    return array.sorted(by: { task1, task2 -> Bool in
        return (!task1.isDone && task2.isDone)
    })
}
