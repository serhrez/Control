//
//  AllTasksVcVM.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import RealmSwift

class AllTasksVcVM {
    typealias TableUpdatesFunc = (_ deletions: [Int], _ insertions: [Int], _ modifications: [Int]) -> Void
    private var projects: [RlmProject] = []
    var models: [Model] {
        projects.map { Model.project($0) } + [.addProject]
    }
    private var tokens: [NotificationToken] = []
    var tableUpdates: TableUpdatesFunc?
    var initialValues: (() -> Void)?
    
    init() {
        PredefinedRealm.populateRealm(RealmProvider.inMemory.realm)
        let token = RealmProvider.inMemory.realm.objects(RlmProject.self).observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: deletions, insertions: insertions, modifications: modifications):
                self.projects = Array(projects.sorted(byKeyPath: "createdAt"))
                self.tableUpdates?(deletions, insertions, modifications)
            case let .initial(projects):
                self.projects = Array(projects.sorted(byKeyPath: "createdAt"))
                self.initialValues?()
            case let .error(error):
                print(error)
            }
        }
        tokens.append(token)
    }
    
    func getProgress(for project: RlmProject) -> Double {
        let count = project.tasks.count
        if count == 0 {
            return 0
        } else {
            return Double(project.tasks.filter { $0.isDone }.count) / Double(count)
        }
    }
    
    enum Model {
        case project(RlmProject)
        case addProject
    }
}
