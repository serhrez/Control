//
//  TagDetailVcVm.swift
//  TodoApp
//
//  Created by sergey on 27.11.2020.
//

import Foundation
import RxDataSources
import RxSwift
import RealmSwift
import RxCocoa

class TagDetailVcVm {
    private var tokens: [NotificationToken] = []
    let tasks = BehaviorRelay<[AnimSection<Model>]>(value: [])
    let tag: RlmTag
    init(tag: RlmTag) {
        self.tag = tag
        updateTasksForTag()
    }
    
    func updateTasksForTag() {
        let token = RealmProvider.main.realm.objects(RlmTask.self).observe(on: .main) { [weak self] (changes) in
            guard let self = self else { return }
            switch changes {
            case let .initial(results), let .update(results, deletions: _, insertions: _, modifications: _):
                let tasks = Array(results).filter { [unowned self] in $0.tags.contains(self.tag) }
                let modelTasks = self.reorderedElements(tasks).map { Model(task: $0) }
                let section = AnimSection(items: modelTasks)
                self.tasks.accept([section])
            case let .error(error):
                print(error)
            }
        }
        tokens.append(token)
    }
    
    func reorderedElements(_ tasks: [RlmTask]) -> [RlmTask] {
        return tasks.sorted(by: { task1, task2 in
            if task2.isDone != task1.isDone {
                return task2.isDone
            }
            return task2.name > task1.name
        })

    }
    
    func getOtherTagThanItself(for task: RlmTask) -> RlmTag? {
        task.tags.filter { [unowned self] in $0 != self.tag }.first
    }
    
    func taskSelected(_ task: RlmTask, isDone: Bool) {
        _ = try! RealmProvider.main.realm.write {
            task.isDone = isDone
        }
//        reorderElements()
    }
}

extension TagDetailVcVm {
    struct Model: IdentifiableType, Equatable {
        var task: RlmTask
        
        var identity: String {
            return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
        }
    }
}
