//
//  CreateProjectVcVm.swift
//  TodoApp
//
//  Created by sergey on 29.11.2020.
//

import Foundation
import RxSwift
import RealmSwift
import RxDataSources
import RxCocoa

class CreateProjectVcVm {
    var project: RlmProject?
    private let bag = DisposeBag()
    private var tokens = [NotificationToken]()
    private let updateTasks = PublishSubject<Void>()
    let tasksUpdate = BehaviorRelay<[AnimSection<Model>]>(value: [.init(items: [])])
    var tasksModel: [AnimSection<Model>] {
        let models = Array(project?.tasks.map { Model.task($0) } ?? [] ) + [.task(RlmTask(name: "gwgwgq", taskDescription: "Sgwgw", isDone: false, date: .init(date: Date(), reminder: .onDay, repeat: .daily), createdAt: Date())), .task(RlmTask())]
        return [AnimSection(items: models)]
    }
    var reloadTasksCells: (_ modifications: [Int]) -> Void = { _ in }
    
    convenience init() {
        let project = RlmProject()
        _ = try! RealmProvider.main.realm.write {
            RealmProvider.main.realm.add(project)
        }
        self.init(project: project)
    }
    
    init(project: RlmProject) {
        self.project = project
        updateTasks.subscribe(onNext: { [unowned self] in self.tasksUpdate.accept(self.tasksModel) }).disposed(by: bag)
        updateTasks.onNext(())
        let tasksToken = project.tasks.observe { [unowned self] changes in
            switch changes {
            case let .error(error):
                print(error)
            case .initial:
                updateTasks.onNext(())
            case .update(_, deletions: _, insertions: _, modifications: let mods):
                updateTasks.onNext(())
                if !mods.isEmpty {
                    reloadTasksCells(mods)
                }
            }
        }
        tokens.append(contentsOf: [tasksToken])
    }
    
    func taskCreated(_ name: String) {
        
    }
}

extension CreateProjectVcVm {
    enum Model: IdentifiableType, Equatable {
        case task(RlmTask)
        case addTask
        
        var identity: String {
            switch self {
            case .addTask:
                return "addTask"
            case let .task(task):
                return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
            }
        }
    }
}
