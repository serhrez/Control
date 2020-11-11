//
//  AllTasksVcVM.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import RealmSwift
import RxSwift

class AllTasksVcVM {
    typealias TableUpdates = (deletions: [Int], insertions: [Int], modifications: [Int])
    typealias TableUpdatesFunc = (_ deletions: [Int], _ insertions: [Int], _ modifications: [Int]) -> Void
    private(set) var projects: [RlmProject] = []
    private var tokens: [NotificationToken] = []
//     let tableUpdatesPublisher = BehaviorSubject<TableUpdates>(value: ([], [], []))
////    var tableUpdatesObservable: Observable<TableUpdates> {
////        tableUpdatesPublisher.asObservable()
////    }
    var tableUpdates: TableUpdatesFunc?
    
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
                self.tableUpdates?([], Array(0..<projects.count),[])
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
}
