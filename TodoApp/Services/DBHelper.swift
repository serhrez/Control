//
//  DBHelper.swift
//  TodoApp
//
//  Created by sergey on 02.01.2021.
//

import Foundation
import RealmSwift

class DBHelper {
    
    // MARK: - Get
    static func getInboxProject(provider: RealmProvider = .main) -> RlmProject {
        return provider.realm.objects(RlmProject.self).first(where: { $0.name == "Inbox" })!
    }
    
    
    // MARK: - Archiving
    static func archive(taskId: String, projectId: String, archiveRealmProvider: RealmProvider = .archive, sourceRealmProvider: RealmProvider = .main) throws {
        guard let task = sourceRealmProvider.realm.objects(RlmTask.self).first(where: { $0.id == taskId }) else { return }
        try archiveRealmProvider.realm.write {
            let task = archiveRealmProvider.realm.create(RlmTask.self, value: task, update: .all)
            let archived = RlmArchived(task: task, projectId: projectId)
            archiveRealmProvider.realm.add(archived)
        }
        try sourceRealmProvider.realm.write {
            sourceRealmProvider.realm.delete(task)
        }
    }
    
    static func unarchive(taskId: String, from sourceProvider: RealmProvider = .archive, to destinationProvider: RealmProvider = .main) throws {
        guard let archivedTask = sourceProvider.realm.objects(RlmArchived.self).first(where: { $0.task?.id == taskId }),
              let unwrapped = archivedTask.task else { return }
        try destinationProvider.realm.write {
            let task = destinationProvider.realm.create(RlmTask.self, value: unwrapped, update: .all)
            let project = destinationProvider.realm.objects(RlmProject.self).first(where: { $0.id == archivedTask.projectId }) ?? getInboxProject(provider: destinationProvider)
            project.tasks.append(task)
        }
        try sourceProvider.realm.write {
            sourceProvider.realm.delete(archivedTask)
        }
    }
}
