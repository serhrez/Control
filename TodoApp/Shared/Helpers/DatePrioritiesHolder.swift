//
//  DatePrioritiesHolder.swift
//  TodoApp
//
//  Created by sergey on 16.12.2020.
//

import Foundation
import RealmSwift

class DatePrioritiesHolder {
    private var datesPrioritiesDict = [Date: Set<Priority>]()
    let provider: RealmProvider
    
    init(provider: RealmProvider = .main) {
        self.provider = provider
    }
    func updateDatesSet() {
        for task in provider.realm.objects(RlmTask.self) where task.date?.date != nil {
            let startDate = task.date!.date!.dateAtStartOf(.day)
            var prioritiesOnDate = datesPrioritiesDict[startDate] ?? []
            prioritiesOnDate.insert(task.priority)
            datesPrioritiesDict[startDate] = prioritiesOnDate
        }
    }

    func datePriorities(_ date: Date) -> (blue: Bool, orange: Bool, red: Bool, gray: Bool) {
        guard let set = datesPrioritiesDict[date.dateAtStartOf(.day)] else { return (false, false, false, false) }
        return (set.contains(.low), set.contains(.medium), set.contains(.high), set.contains(.none))
    }

}
