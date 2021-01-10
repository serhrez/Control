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
        RealmProvider.archive.safeWrite {
            RealmProvider.archive.realm.add(archived)
        }
    }
    
    func delete(archived: RlmArchived) {
        RealmProvider.archive.safeWrite {
            RealmProvider.archive.realm.cascadeDelete(archived)
        }
    }
    
    func unrestore(taskId: String, projectId: String) {
        DBHelper.safeArchive(taskId: taskId, projectId: projectId)
    }
    
    func restoreTask(taskId: String) {
        DBHelper.safeUnarchive(taskId: taskId)
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
