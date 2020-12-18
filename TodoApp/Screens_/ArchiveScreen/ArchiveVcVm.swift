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
    var models = BehaviorRelay<[Model]>(value: [])
    init() {
        archived = Array(RealmProvider.main.realm.objects(RlmArchived.self))
        archivedSetId = Set(archived.map { $0.taskId })
        tasks = Array(RealmProvider.main.realm.objects(RlmTask.self).filter { self.archivedSetId.contains($0.id) })
        models.accept(tasks.map { Model.init(task: $0, state: .none) })
    }
    
    func updateState(item: Int, state: State) {
        var modelsValue = self.models.value
        var model = modelsValue[item]
        model.state = state
        modelsValue[item] = model
        self.models.accept(modelsValue)
    }
        
    func clickedOnCellCheckbox(item: Int, with state: CheckboxViewArchive.State) {
        switch state {
        case .checked:
            updateTask(item: item) { $0.isDone = false }
        case .unchecked:
            updateTask(item: item) { $0.isDone = true }
        case .restore, .delete:
            updateModel(item: item) { $0.state = .none }
        }
    }
    
    private func updateModel(item: Int, update: (inout Model) -> Void) {
        var modelsValue = self.models.value
        var model = modelsValue[item]
        update(&model)
        modelsValue[item] = model
        self.models.accept(modelsValue)
    }
    
    private func updateTask(item: Int, update: (RlmTask) -> Void) {
        let task = self.models.value[item].task
        _ = try! RealmProvider.main.realm.write {
            update(task)
        }
        updateModel(item: item) { model in
            model.task = task
        }
    }

}

extension ArchiveVcVm {
    struct Model: UpdateDiffModel {
        private(set) var frozentask: RlmTask
        var task: RlmTask {
            didSet {
                frozentask = task.freeze()
            }
        }
        var state: State
        init(task: RlmTask, state: State) {
            self.frozentask = task.freeze()
            self.state = state
            self.task = task
        }
        var diffId: String {
            return task.isInvalidated ? "\(UUID().uuidString)" : task.id
        }
        var updateId: String {
            return state.rawValue + "\(frozentask.isDone)"
        }
    }
    enum State: String {
        case none
        case delete
        case restore
    }
}
