//
//  CalendarVcVm.swift
//  TodoApp
//
//  Created by sergey on 25.11.2020.
//

import Foundation
import SwiftDate
import RealmSwift

class CalendarVcVm {
    let taskDate: RlmTaskDate
    var onUpdate: (() -> Void)?
    var formattedTimeText: String? {
        taskDate.date?.toFormat("HH:mm")
    }
    private var tokens: [NotificationToken] = []
    
    init(taskDate: RlmTaskDate) {
        self.taskDate = taskDate
        let taskDateToken = taskDate.observe { [unowned self] _ in
            self.onUpdate?()
        }
        tokens.append(contentsOf: [taskDateToken])
    }
    func selectDate(_ date: Date) {
        setNewDateWithPreviousSeconds(date)
    }
    
    func datePriorities(_ date: Date) -> (blue: Bool, orange: Bool, red: Bool) {
        return (false, false, false)
    }
    
    private func setNewDateWithPreviousSeconds(_ date: Date) {
        guard let dateSeconds = taskDate.date?.second else {
            _ = try! RealmProvider.inMemory.realm.write {
                taskDate.date = date
            }
            return
        }
        var todayDate = getDateWithoutSeconds(date)
        todayDate = todayDate + dateSeconds.seconds
        _ = try! RealmProvider.inMemory.realm.write {
            taskDate.date = todayDate
        }
        print("date selected: \(taskDate.date?.toFormat("MM-dd-yyyy HH:mm"))")
    }
    private func getDateWithoutSeconds(_ date: Date) -> Date {
        var date = date
        date = date - date.second.seconds
        return date
    }
    
    func clickedToday() {
        setNewDateWithPreviousSeconds(DateInRegion().date)
    }
    func clickedTomorrow() {
        setNewDateWithPreviousSeconds(DateInRegion().date + 1.days)
    }
    func clickedNextMonday() {
        setNewDateWithPreviousSeconds(DateInRegion().date.nextWeekday(.monday))
    }
    func clickedEvening() {
        var date = taskDate.date ?? DateInRegion().date
        if date.hour < 18 {
            date = getDateWithoutSeconds(date)
            date = date + 18.hours
            _ = try! RealmProvider.inMemory.realm.write {
                taskDate.date = date
            }
        }
    }
    
    func reminderSelected(_ reminder: Reminder?) {
        _ = try! RealmProvider.inMemory.realm.write {
            taskDate.reminder = reminder
        }
    }
    
    func repeatSelected(_ repeatx: Repeat?) {
        _ = try! RealmProvider.inMemory.realm.write {
            taskDate.repeat = repeatx
        }
    }
}
