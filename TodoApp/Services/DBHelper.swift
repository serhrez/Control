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
        return provider.realm.objects(RlmProject.self).first(where: { $0.id == Constants.inboxId })!
    }
    
    
    // MARK: - Archiving
    static func archive(taskId: String, projectId: String, archiveRealmProvider: RealmProvider = .archive, sourceRealmProvider: RealmProvider = .main) throws {
        guard let task = sourceRealmProvider.realm.objects(RlmTask.self).first(where: { $0.id == taskId }) else { return }
        Notifications.shared.removeNotifications(id: task.id)
        try archiveRealmProvider.realm.write {
            let task = archiveRealmProvider.realm.create(RlmTask.self, value: task, update: .all)
            let archived = RlmArchived(task: task, projectId: projectId)
            archiveRealmProvider.realm.add(archived)
        }
        try sourceRealmProvider.realm.write {
            sourceRealmProvider.realm.cascadeDelete(task)
        }
    }
    
    static func unarchive(taskId: String, from sourceProvider: RealmProvider = .archive, to destinationProvider: RealmProvider = .main) throws {
        guard let archivedTask = sourceProvider.realm.objects(RlmArchived.self).first(where: { $0.task?.id == taskId }),
              let unwrapped = archivedTask.task else { return }
        try destinationProvider.realm.write {
            let task = destinationProvider.realm.create(RlmTask.self, value: unwrapped, update: .all)
            let project = destinationProvider.realm.objects(RlmProject.self).first(where: { $0.id == archivedTask.projectId }) ?? getInboxProject(provider: destinationProvider)
            project.tasks.append(task)
            RealmStore.main.updateDateDependencies(in: task)
        }
        try sourceProvider.realm.write {
            sourceProvider.realm.cascadeDelete(archivedTask)
        }
    }
}

extension DBHelper {
    static func safeArchive(taskId: String, projectId: String, archiveRealmProvider: RealmProvider = .archive, sourceRealmProvider: RealmProvider = .main) {
        do {
            try archive(taskId: taskId, projectId: projectId, archiveRealmProvider: archiveRealmProvider, sourceRealmProvider: sourceRealmProvider)
        } catch {
            print("⚠️⚠️⚠️ Realm error: \(error.localizedDescription)")
            #if DEBUG
                fatalError()
            #endif
        }
    }
    
    static func safeUnarchive(taskId: String, from sourceProvider: RealmProvider = .archive, to destinationProvider: RealmProvider = .main) {
        do {
            try unarchive(taskId: taskId, from: sourceProvider, to: destinationProvider)
        } catch {
            print("⚠️⚠️⚠️ Realm error: \(error.localizedDescription)")
            #if DEBUG
                fatalError()
            #endif
        }
    }
}
