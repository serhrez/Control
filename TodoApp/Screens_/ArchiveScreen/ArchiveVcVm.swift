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
    private var archived: [RlmArchived] = []
    private var archivedSetId = Set<String>()
    private var tasks: [RlmTask] = []
    var models = [AnimSection<Model>(items: [])]
    init() {
        archived = Array(RealmProvider.main.realm.objects(RlmArchived.self))
        archivedSetId = Set(archived.map { $0.taskId })
        tasks = Array(RealmProvider.main.realm.objects(RlmTask.self).filter { self.archivedSetId.contains($0.id) })
        models = ([AnimSection(items: tasks.map { Model.init(task: $0, state: .none) }) ])
    }
}

extension ArchiveVcVm {
    struct Model: IdentifiableType, Equatable {
        var task: RlmTask
        var state: State
        var identity: String {
            return task.isInvalidated ? "\(UUID().uuidString)" : task.id
        }
    }
    enum State {
        case none
        case delete
        case restore
    }
}
