//
//  PredefinedRealm.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import RealmSwift

class PredefinedRealm {
    static func populateRealm(_ realm: Realm) {
        _ = try? realm.write {
            let tag1 = RlmTag(name: "tag1")
            let tag2 = RlmTag(name: "tag2")
            let tag3 = RlmTag(name: "tag3")
            let tag4 = RlmTag(name: "tag4")

            let project1 = RlmProject(name: "Inbox", icon: .assetImage(name: "Image", tintHex: "#571cff"), notes: "", color: .hex("#571cff"), date: Date())
            var task = RlmTask(name: "Task1", isDone: false)
            task.tags.append(tag1)
            project1.tasks.append(task)
            task = RlmTask(name: "Task2", isDone: true)
            task.tags.append(tag2)
            project1.tasks.append(task)
            task = RlmTask(name: "Task3", isDone: true)
            task.tags.append(tag3)
            project1.tasks.append(task)
            task = RlmTask(name: "Task4", isDone: true)
            task.tags.append(tag4)
            project1.tasks.append(task)

            let project2 = RlmProject(name: "Work", icon: .text("🚒"), notes: "", color: .hex("#00CE15"), date: Date())
            task = RlmTask(name: "Task1", isDone: true)
            task.tags.append(tag1)
            project2.tasks.append(task)
            task = RlmTask(name: "Task2", isDone: true)
            task.tags.append(tag2)
            project2.tasks.append(task)
            task = RlmTask(name: "Task3", isDone: true)
            task.tags.append(tag3)
            project2.tasks.append(task)
            task = RlmTask(name: "Task4", isDone: true)
            task.tags.append(tag4)
            project2.tasks.append(task)
            project2.tasks.append(RlmTask(name: "Task4", isDone: false))
            project2.tasks.append(RlmTask(name: "Task5", isDone: false))
            project2.tasks.append(RlmTask(name: "Task6", isDone: false))
            
            let project3 = RlmProject(name: "Work", icon: .text("🏝"), notes: "", color: .hex("#447bfe"), date: Date())
            project3.tasks.append(RlmTask(name: "Task1", isDone: true))
            project3.tasks.append(RlmTask(name: "Task2", isDone: true))
            project3.tasks.append(RlmTask(name: "Task3", isDone: true))
            task = RlmTask(name: "Task4", isDone: true)
            task.tags.append(tag1)
            project3.tasks.append(task)
            task = RlmTask(name: "Task5", isDone: true)
            task.tags.append(tag2)
            project3.tasks.append(task)
            task = RlmTask(name: "Task6", isDone: true)
            task.tags.append(tag2)
            project3.tasks.append(task)
            task = RlmTask(name: "Task7", isDone: true)
            task.tags.append(tag2)
            project3.tasks.append(task)

            realm.add(project1)
            realm.add(project2)
            realm.add(project3)
            
//            let tags5to11 = Array(5...9).map { RlmTag(name: "tag\($0)")}
//            realm.add(tags5to11)
        }
    }
}
