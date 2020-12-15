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
import RealmSwift

class CalendarVcVm {
    
    let reminder: BehaviorRelay<Reminder?>
    let `repeat`: BehaviorRelay<Repeat?>
    // Bool - is update from calendarView?
    let date: BehaviorRelay<(Date?, Bool?)>
    private let datePrioritiesHolder = DatePrioritiesHolder()

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
        date.accept((Date().dateBySet(hour: date.value.0?.hour, min: date.value.0?.minute, secs: date.value.0?.second), false))
    }
    func clickedTomorrow() {
        date.accept((Date().dateAt(.tomorrowAtStart).dateBySet(hour: date.value.0?.hour, min: date.value.0?.minute, secs: date.value.0?.second), false))
    }
    func clickedNextMonday() {
        var nextWeekday = Date().nextWeekday(.monday)
        if Date().isInside(date: nextWeekday, granularity: .weekOfMonth) {
            nextWeekday = nextWeekday.nextWeekday(.tuesday).nextWeekday(.monday)
        }

        date.accept((nextWeekday.dateBySet(hour: date.value.0?.hour, min: date.value.0?.minute, secs: date.value.0?.second), false))
    }
    func clickedEvening() {
        if date.value.0.flatMap({ $0.hour < 18 }) ?? true {
            date.accept(((date.value.0 ?? Date()).dateBySet(hour: 19, min: date.value.0?.minute, secs: 0), false))
        }
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
}

fileprivate struct DatePriority: Hashable {
    var date: Date
    var priority: Priority
}
