//
//  ArchiveVcVm.swift
//  TodoApp
//
//  Created by sergey on 16.12.2020.
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift
import RxCocoa
import SwiftDate

class ArchiveVcVm {
    private let bag = DisposeBag()
    private var tokens: [NotificationToken] = []
    private(set) var archived: [RlmArchived] = [] {
        didSet {
            modelsSubject.onNext([AnimSection(items: archived.map { Model(task: $0) })])
        }
    }
    var modelsSubject = PublishSubject<[AnimSection<Model>]>()
    init() {
        archived = Array(RealmProvider.archive.realm.objects(RlmArchived.self))
        let token = RealmProvider.archive.realm.objects(RlmArchived.self).observe(on: .main) { [weak self] changes in
            switch changes {
            case let .error(error): print(error)
            case let .initial(results):
                self?.archived = Array(results.sorted(by: { $0.timeDeleted > $1.timeDeleted }))
            case let .update(results, deletions: _, insertions: _, modifications: _): self?.archived = Array(results.sorted(by: { $0.timeDeleted > $1.timeDeleted }))
            }
        }
        tokens.append(token)
    }
    
    func add(archived: RlmArchived) {
        _ = try! RealmProvider.archive.realm.write {
            RealmProvider.archive.realm.add(archived)
        }
    }
    
    func delete(archived: RlmArchived) {
        _ = try! RealmProvider.archive.realm.write {
            RealmProvider.archive.realm.delete(archived)
        }
    }
    
    func unrestore(taskId: String, projectId: String) {
        _ = try! DBHelper.archive(taskId: taskId, projectId: projectId)
    }
    
    func restoreTask(taskId: String) {
        _ = try! DBHelper.unarchive(taskId: taskId)
    }
}

extension ArchiveVcVm {
    struct Model: IdentifiableType, Equatable {
        var task: RlmArchived
        
        var identity: String {
            task.isInvalidated ? "deleted-\(UUID().uuidString)" : (task.task?.id ?? UUID().uuidString)
        }
    }
}
