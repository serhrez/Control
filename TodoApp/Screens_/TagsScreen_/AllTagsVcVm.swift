//
//  AllTagsVcVm.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import RealmSwift

class AllTagsVcVm {
    typealias TableUpdatesFunc = (_ deletions: [Int], _ insertions: [Int], _ modifications: [Int]) -> Void
    private(set) var tags: [RlmTag] = []
    private var tokens: [NotificationToken] = []
    var tableUpdates: TableUpdatesFunc?
    var initialValues: (() -> Void)?

    init() {
        PredefinedRealm.populateRealm(RealmProvider.inMemory.realm)
        let token = RealmProvider.inMemory.realm.objects(RlmTag.self).observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: deletions, insertions: insertions, modifications: modifications):
                self.tags = Array(projects.sorted(byKeyPath: "createdAt"))
                self.tableUpdates?(deletions, insertions, modifications)
            case let .initial(projects):
                self.tags = Array(projects.sorted(byKeyPath: "createdAt"))
                self.initialValues?()
            case let .error(error):
                print(error)
            }
        }
        tokens.append(token)
    }

    func allTasksCount(for tag: RlmTag) -> Int {
        return         RealmProvider.inMemory.realm.objects(RlmTask.self).filter { $0.tags.contains(where: { $0.id == tag.id }) }.count

    }
    
}
