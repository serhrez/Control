//
//  TasksCountProvider.swift
//  TodoApp
//
//  Created by sergey on 28.02.2021.
//

import WidgetKit
import SwiftUI
import SwiftDate

struct TasksCountEntry: TimelineEntry {
    let date: Date
    let tasksCount: Int
}

struct TasksCountProvider: TimelineProvider {
    
    var mode: Mode
    func getSnapshot(in context: Context, completion: @escaping (TasksCountEntry) -> Void) {
        let count = getCounts()
        let entry = TasksCountEntry(date: .init(), tasksCount: count)
        completion(entry)
    }
        
    func getTimeline(in context: Context, completion: @escaping (Timeline<TasksCountEntry>) -> Void) {
        let count = getCounts()
        let entry = TasksCountEntry(date: .init(), tasksCount: count)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> TasksCountEntry {
        .init(date: .init(), tasksCount: 0)
    }
    
    func getCounts() -> Int {
        let count: Int
        switch mode {
        case .inbox:
            count = RealmProvider.main.realm.objects(RlmProject.self).first(where: { $0.id == Constants.inboxId })?.tasks.count ?? 0
        case .priority:
            count = RealmProvider.main.realm.objects(RlmTask.self).filter { $0.priority != .none }.count
        case .today:
            count = RealmProvider.main.realm.objects(RlmTask.self).filter { $0.date?.date?.isToday ?? false }.count
        case .upcoming:
            let nowDate = Date().dateAt(.startOfDay)
            let dateInWeek = nowDate + 1.weeks
            count = RealmProvider.main.realm.objects(RlmTask.self).compactMap { $0.date?.date }.filter { $0 >= nowDate && $0 <= dateInWeek }.count
        }
        return count
    }
}

extension TasksCountProvider {
    enum Mode {
        case upcoming
        case today
        case inbox
        case priority
    }
}
