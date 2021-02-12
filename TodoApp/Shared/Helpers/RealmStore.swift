//
//  RealmStore.swift
//  TodoApp
//
//  Created by sergey on 12.02.2021.
//

import Foundation
import RealmSwift

class RealmStore {
    
    static let main = RealmStore(provider: .main)
    private let provider: RealmProvider
    
    private init(provider: RealmProvider) {
        self.provider = provider
    }
            
    func updateDateDependencies(in task: RlmTask) {
        guard task.realm != nil else { return }
        Notifications.shared.removeNotifications(id: task.id)
        if let date = task.date?.date, !task.isDone {
            Notifications.shared.scheduleTask(task: task.freeze(), date: date, reminder: task.date?.reminder, repeatt: task.date?.repeat)
        }
    }
}
