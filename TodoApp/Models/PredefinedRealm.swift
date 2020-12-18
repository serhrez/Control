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

            let project1 = RlmProject(name: "Inbox", icon: .assetImage(name: "Image", tintHex: "#571cff"), notes: "", color: .hex("#571cff"), date: Date())
            var task = RlmTask(name: "Make design for My Plan App", taskDescription: "Plan! - Create app for iOs and Testing app for iPadOs, MacOs send to server.", isDone: false)
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
            task = RlmTask(name: "Plan! - Create app for iOs and Testing app for iPadOs, MacOs send to server.", isDone: true)
            task.date = RlmTaskDate(date: Date(), reminder: .onDay, repeat: .monthly)
            task.priority = .high
            project1.tasks.append(task)
            task = RlmTask(name: "Task3", isDone: false)
            task.priority = .medium

            task.date = .init(date: Date().dateAt(.nextWeek), reminder: .threeDaysEarlier, repeat: nil)
            project1.tasks.append(task)
            task = RlmTask(name: "Task4", isDone: true)
            task.subtask.append(RlmSubtask(name: "Subtask1"))
            task.tags.append(tag4)
            project1.tasks.append(task)
            var datereferencex = Date().dateAt(.nextWeek)
            let project2 = RlmProject(name: "Work", icon: .text("🚒"), notes: "", color: .hex("#00CE15"), date: Date())
            task = RlmTask(name: "Task1", isDone: true)
            task.tags.append(tag1)
            task.priority = .low
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project2.tasks.append(task)
            task = RlmTask(name: "Task2", isDone: true)
            task.priority = .high
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project2.tasks.append(task)
            task = RlmTask(name: "Task3", isDone: true)
            task.tags.append(tag3)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project2.tasks.append(task)
            task = RlmTask(name: "Task4", isDone: true)
            task.tags.append(tag4)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project2.tasks.append(task)
            task = RlmTask(name: "Task4", isDone: false)
            realm.add(RlmArchived(taskId: task.id, timeDeleted: Date()))
            project2.tasks.append(task)
            project2.tasks.append(RlmTask(name: "Task5", isDone: false))
            project2.tasks.append(RlmTask(name: "Task6", isDone: false))

            let project3 = RlmProject(name: "Work", icon: .text("🏝"), notes: "", color: .hex("#447bfe"), date: Date())
            project3.tasks.append(RlmTask(name: "Task1", isDone: true))
            project3.tasks.append(RlmTask(name: "Task2", isDone: true))
            project3.tasks.append(RlmTask(name: "Task3", isDone: true))
            task = RlmTask(name: "Task4", isDone: true)
            task.tags.append(tag1)
            datereferencex = datereferencex.dateAt(.tomorrow)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)
            task = RlmTask(name: "Task5", isDone: true)
            task.tags.append(tag2)
            datereferencex = datereferencex.dateAt(.tomorrow)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)
            task = RlmTask(name: "Task6", isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)
            task = RlmTask(name: "Task7", isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)
            
            task = RlmTask(name: "Task8", isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task9", isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task10", isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task11", isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task12", isDone: true)
            task.tags.append(tag2)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task13", isDone: true)
            task.tags.append(tag3)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)
            realm.add(RlmArchived(taskId: task.id, timeDeleted: Date()))


            task = RlmTask(name: "Task14", isDone: true)
            task.tags.append(tag2)
            datereferencex = datereferencex.dateAt(.tomorrow)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)

            task = RlmTask(name: "Task15", isDone: true)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)
            realm.add(RlmArchived(taskId: task.id, timeDeleted: Date()))

            task = RlmTask(name: "Task16", isDone: true)
            task.tags.append(tag1)
            task.date = .init(date: datereferencex, reminder: .threeDaysEarlier, repeat: nil)
            project3.tasks.append(task)

            
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
