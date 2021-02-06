//
//  PredefinedRealm.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import RealmSwift
import SwiftDate

class PredefinedRealm {
    static func populateRealm(_ realm: Realm) {
        do {
        try realm.write {
            let tag1 = RlmTag(name: "Design")
            let tag2 = RlmTag(name: "Work")
            let tag3 = RlmTag(name: "Plan")
            let tag4 = RlmTag(name: "tag4")

            let project1 = RlmProject(name: "Inbox", icon: .assetImage(name: "inboximg", tintHex: "#571cff"), notes: "", color: .hex("#571cff"), date: Date())
            project1.id = Constants.inboxId
            var task = RlmTask(name: "Make design for My Plan App", taskDescription: "Plan! - Create app for iOs and Testing app for iPadOs, MacOs send to server.", priority: .medium, isDone: false)
            task.subtask.append(RlmSubtask(name: "Subtask1"))
            task.subtask.append(RlmSubtask(name: "Subtask2"))
            task.subtask.append(RlmSubtask(name: "qwg"))
            task.subtask.append(RlmSubtask(name: "gqgqrgqw"))
            task.subtask.append(RlmSubtask(name: "bdsbzxv"))
            task.subtask.append(RlmSubtask(name: "lp;,l wqmlfqw"))
            task.subtask.append(RlmSubtask(name: "Qwerty lol"))
            task.subtask.append(RlmSubtask(name: "уцйуйк lol"))


            task.date = .init(date: Date(timeIntervalSince1970: .init(223_313_131)), reminder: nil, repeat: nil)
            task.tags.append(tag1)
            task.tags.append(tag2)
            task.tags.append(tag4)
            project1.tasks.append(task)
            task = RlmTask(name: "Plan! - Create app for iOs and Testing app for iPadOs, MacOs send to server.", priority: .medium, isDone: true)
            task.date = RlmTaskDate(date: Date(), reminder: .fiveMinutesBefore, repeat: .everyMonth)
            task.priority = .high
            project1.tasks.append(task)
            task = RlmTask(name: "Task3", priority: .medium, isDone: false)
            task.priority = .medium

            task.date = .init(date: Date().dateAt(.nextWeek), reminder: .oneDayEarly, repeat: nil)
            project1.tasks.append(task)
            task = RlmTask(name: "Task4", priority: .medium, isDone: true)
            task.subtask.append(RlmSubtask(name: "Subtask1"))
            task.tags.append(tag4)
            project1.tasks.append(task)
            var datereferencex = Date().dateAt(.nextWeek)
            let project2 = RlmProject(name: "Work", icon: .text("🚒"), notes: "", color: .hex("#00CE15"), date: Date())
            task = RlmTask(name: "Task1", priority: .medium, isDone: true)
            task.tags.append(tag1)
            task.priority = .low
            task.date = .init(date: datereferencex, reminder: .tenMinutesBefore, repeat: nil)
            project2.tasks.append(task)
            task = RlmTask(name: "Task2", priority: .medium, isDone: true)
            task.priority = .high
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .thirtyMinutesBefore, repeat: nil)
            project2.tasks.append(task)
            task = RlmTask(name: "Task3", priority: .medium, isDone: true)
            task.tags.append(tag3)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project2.tasks.append(task)
            task = RlmTask(name: "Task4", priority: .low, isDone: true)
            task.tags.append(tag4)
            task.date = .init(date: datereferencex, reminder: .tenMinutesBefore, repeat: nil)
            project2.tasks.append(task)
            task = RlmTask(name: "Empty task", priority: .low, isDone: true)
            task.tags.append(tag4)
            task.date = .init(date: datereferencex, reminder: .thirtyMinutesBefore, repeat: nil)
            project2.tasks.append(task)
            task = RlmTask(name: "Task4", priority: .low, isDone: false)
            project2.tasks.append(task)
            project2.tasks.append(RlmTask(name: "Task5", priority: .high, isDone: false))
            project2.tasks.append(RlmTask(name: "Task6", priority: .low, isDone: false))

            let project3 = RlmProject(name: "Work", icon: .text("🏝"), notes: "", color: .hex("#447bfe"), date: Date())
            project3.tasks.append(RlmTask(name: "Task1", priority: .medium, isDone: true))
            project3.tasks.append(RlmTask(name: "Task2", priority: .none, isDone: true))
            project3.tasks.append(RlmTask(name: "Task3", priority: .none, isDone: true))
            task = RlmTask(name: "Task4", priority: .medium, isDone: true)
            task.tags.append(tag1)
            datereferencex = datereferencex.dateAt(.tomorrow)
            task.date = .init(date: datereferencex, reminder: .fiveMinutesBefore, repeat: nil)
            project3.tasks.append(task)
            task = RlmTask(name: "Task5", priority: .none, isDone: true)
            task.tags.append(tag2)
            datereferencex = datereferencex.dateAt(.tomorrow)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)
            task = RlmTask(name: "Task6", priority: .medium, isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: nil, repeat: nil)
            project3.tasks.append(task)
            task = RlmTask(name: "Task7", priority: .high, isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)
            
            task = RlmTask(name: "Task8", priority: .none, isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task9", priority: .none, isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task10", priority: .none, isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task11", priority: .none, isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task12", priority: .none, isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task13", priority: .high, isDone: true)
            task.tags.append(tag3)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)


            task = RlmTask(name: "Task14", priority: .none, isDone: true)
            task.tags.append(tag2)
            datereferencex = datereferencex.dateAt(.tomorrow)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task15", priority: .medium, isDone: true)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task16", priority: .none, isDone: true)
            task.tags.append(tag1)
            task.date = .init(date: datereferencex, reminder: .oneDayEarly, repeat: nil)
            project3.tasks.append(task)
            
//            var tasks: [RlmTask] = []
//            for i in 1...1200 {
//                let task = RlmTask(name: "Task:\(i)", priority: Int.random(in: 1...3) == 1 ? .high : .medium, isDone: Int.random(in: 1...2) == 1 ? true : false)
//                var date: Date = Date()
//                switch Int.random(in: 1...3) {
//                case 1:
//                    date = date.dateAt(.nextMonth)
//                case 2:
//                    date = date.dateAt(.nearestHour(hour: 22))
//                default:
//                    date = date.dateAt(.nextWeek)
//                }
//                task.date = .init(date: date, reminder: .fiveMinutesEarly, repeat: .monthly)
//                tasks.append(task)
//            }
//            project3.tasks.append(objectsIn: tasks)
            
            realm.add(project1)
            realm.add(project2)
            realm.add(project3)

            let tags5to11 = Array(5...9).map { RlmTag(name: "tag\($0)")}
            realm.add(tags5to11)
        }
        } catch {
            print(error.localizedDescription)
        }
    }
}
