//
//  CalendarVcVm.swift
//  TodoApp
//
//  Created by sergey on 25.11.2020.
//

import Foundation
import SwiftDate
import RxSwift
import RxCocoa

class CalendarVcVm {
    
    let reminder: BehaviorRelay<Reminder?>
    let `repeat`: BehaviorRelay<Repeat?>
    // Bool - is update from calendarView?
    let date: BehaviorRelay<(Date?, Bool?)>
    var shouldGoBackAndSave: () -> Void = { }
    private let datePrioritiesHolder = DatePrioritiesHolder()
    private let nowDate = Date()

    init(reminder: Reminder?, repeat: Repeat?, date: Date?) {
        self.reminder = .init(value: reminder)
        self.repeat = .init(value: `repeat`)
        self.date = .init(value: (date, nil))
        datePrioritiesHolder.updateDatesSet()
    }
    
    func datePriorities(_ date: Date) -> (blue: Bool, orange: Bool, red: Bool, gray: Bool) {
        datePrioritiesHolder.datePriorities(date)
    }
    
    func selectDayFromJct(_ datex: Date) {
        date.accept((datex.dateBySet(hour: date.value.0?.hour ?? Date().hour, min: date.value.0?.minute ?? Date().hour, secs: date.value.0?.second), true))
    }
    
    func clickedToday() {
        date.accept((getTodayDate(), false))
    }
    func clickedTomorrow() {
        date.accept((getTomorrowDate(), false))
    }
    func clickedNextMonday() {
        date.accept((getNextMondayDate(), false))
    }
    func clickedEvening() {
        date.accept((getEveningDate(), false))
    }
    
    func reminderSelected(_ reminder: Reminder?) {
        self.reminder.accept(reminder)
    }
    
    func repeatSelected(_ repeatx: Repeat?) {
        self.repeat.accept(repeatx)
    }
    
    func timeSelected(hours: Int, minutes: Int) {
        let currDate = (date.value.0 ?? Date()).dateBySet(hour: hours, min: minutes, secs: 0)
        self.date.accept((currDate, false))
    }
    
    func clearAll() {
        date.accept((nil, false))
        self.repeat.accept(nil)
        self.reminder.accept(nil)
    }
    
    func getEveningDate() -> Date {
        let todayDate = Date()
        let dateAt18 = todayDate.dateBySet(hour: 18, min: 0, secs: 0) ?? Date()
        guard let userDate = date.value.0 else {
            if dateAt18 >= todayDate {
                return dateAt18
            }
            return Date().dateAt(.tomorrow).dateBySet(hour: 18, min: 0, secs: 0) ?? Date()
        }
        let userDateAt18 = userDate.dateBySet(hour: 18, min: 0, secs: 0) ?? Date()
        let max: Date = dateAt18 > userDateAt18 ? dateAt18 : userDateAt18
        if max >= todayDate {
            return max
        }
        return Date().dateAt(.tomorrow).dateBySet(hour: 18, min: 0, secs: 0) ?? Date()
    }

    func getNextMondayDate() -> Date {
        let today = Date()
        let datePoint = date.value.0 ?? Date().dateBySet(hour: 12, min: 0, secs: 0)
        let nextMonday = today.nextWeekday(.monday)
        return nextMonday.dateBySet(hour: datePoint?.hour, min: datePoint?.minute, secs: 0) ?? nextMonday
    }
    
    func getTomorrowDate() -> Date {
        let datePoint = date.value.0 ?? Date().dateBySet(hour: 12, min: 0, secs: 0) ?? Date()
        let date = Date().dateAt(.tomorrowAtStart).dateBySet(hour: datePoint.hour, min: datePoint.minute, secs: datePoint.second)

        return date ?? Date().dateAt(.tomorrowAtStart)
    }
    
    func getTodayDate() -> Date {
        guard let todayDate = nowDate.dateBySet(hour: date.value.0?.hour, min: date.value.0?.minute, secs: date.value.0?.second) else {
            return nowDate
        }
        if todayDate < nowDate {
            return nowDate.dateAt(.nearestMinute(minute: 1))
        }
        return todayDate
    }
}

fileprivate struct DatePriority: Hashable {
    var date: Date
    var priority: Priority
}
