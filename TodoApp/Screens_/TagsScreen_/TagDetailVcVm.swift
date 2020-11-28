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
    private let tokens: [NotificationToken] = []
    let tasks = BehaviorRelay<[AnimSection<Model>]>(value: [])
    let tag: RlmTag
    init(tag: RlmTag) {
        self.tag = tag
        updateTasksForTag()
        reorderElements()
    }
    
    func updateTasksForTag() {
        let tasks = Array(RealmProvider.main.realm.objects(RlmTask.self)).filter { [unowned self] in $0.tags.contains(self.tag) }.map { Model(task: $0) }
        let animSect = AnimSection(identity: "qwe", items: tasks)
        self.tasks.accept([animSect])
    }
    
    func reorderElements() {
        var items = self.tasks.value[0].items.map { $0.task }
        items.sort(by: { task1, task2 in
            if task2.isDone != task1.isDone {
                return task2.isDone
            }
            return task2.name > task1.name
        })
        self.tasks.accept([AnimSection(identity: "qwe", items: items.map { Model(task: $0) })])
    }
    
    func getOtherTagThanItself(for task: RlmTask) -> RlmTag? {
        task.tags.filter { [unowned self] in $0 != self.tag }.first
    }
    
    func taskSelected(_ task: RlmTask, isDone: Bool) {
        _ = try! RealmProvider.main.realm.write {
            task.isDone = isDone
        }
        reorderElements()
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
