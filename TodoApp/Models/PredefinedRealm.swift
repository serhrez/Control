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
            let project1 = RlmProject(name: "Inbox", icon: .assetImage("Image"), notes: "", color: .hex("#571cff"), date: Date())
            project1.tasks.append(RlmTask(name: "Task1", isDone: false))
            project1.tasks.append(RlmTask(name: "Task2", isDone: true))
            project1.tasks.append(RlmTask(name: "Task3", isDone: true))
            project1.tasks.append(RlmTask(name: "Task4", isDone: true))

            let project2 = RlmProject(name: "Work", icon: .text("🚒"), notes: "", color: .hex("#00CE15"), date: Date())
            project2.tasks.append(RlmTask(name: "Task1", isDone: true))
            project2.tasks.append(RlmTask(name: "Task2", isDone: true))
            project2.tasks.append(RlmTask(name: "Task3", isDone: false))
            project2.tasks.append(RlmTask(name: "Task4", isDone: false))
            project2.tasks.append(RlmTask(name: "Task5", isDone: false))
            project2.tasks.append(RlmTask(name: "Task6", isDone: false))
            
            let project3 = RlmProject(name: "Work", icon: .text("🏝"), notes: "", color: .hex("#447bfe"), date: Date())
            project3.tasks.append(RlmTask(name: "Task1", isDone: true))
            project3.tasks.append(RlmTask(name: "Task2", isDone: true))
            project3.tasks.append(RlmTask(name: "Task3", isDone: true))
            project3.tasks.append(RlmTask(name: "Task4", isDone: true))
            project3.tasks.append(RlmTask(name: "Task5", isDone: true))
            project3.tasks.append(RlmTask(name: "Task6", isDone: true))
            project3.tasks.append(RlmTask(name: "Task7", isDone: true))

            realm.add(project1)
            realm.add(project2)
            realm.add(project3)
        }
    }
}
