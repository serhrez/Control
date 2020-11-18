//
//  InboxTasksVcVm.swift
//  TodoApp
//
//  Created by sergey on 17.11.2020.
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift

class InboxTasksVcVm {
    private let bag = DisposeBag()
    private(set) var tasks: [RlmTask] = []
    private let modelsUpdateSubject = PublishSubject<Void>()
    private var tokens: [NotificationToken] = []
    
    lazy var modelsUpdate: Observable<[AnimSection<Model>]> = modelsUpdateSubject.compactMap { [weak self] in self?.models }.share(replay: 1, scope: .whileConnected)
    var models: [AnimSection<Model>] {
        let section1 = tasks.filter { !$0.isDone }.map { Model.task($0) }
        let section2 = tasks.filter { $0.isDone }.map { Model.doneTask($0) }
        return [AnimSection(identity: "section1", items: section1), AnimSection(identity: "section2", items: section2)]
    }
    
    init() {
        modelsUpdate.subscribe().disposed(by: bag)
        let rlmProject = RealmProvider.inMemory.realm.objects(RlmProject.self).filter { $0.name == "Inbox" }.first!
        let token = rlmProject.tasks.observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: _, insertions: _, modifications: _):
                self.tasks = Array(projects.sorted(byKeyPath: "createdAt"))
            case let .initial(projects):
                self.tasks = Array(projects.sorted(byKeyPath: "createdAt"))
            case let .error(error):
                print(error)
            }
            self.modelsUpdateSubject.onNext(())
        }
        tokens.append(token)
    }
}

extension InboxTasksVcVm {
    enum Model: IdentifiableType, Equatable {
        case task(RlmTask)
        case doneTask(RlmTask)
        
        var identity: String {
            switch self {
            case .task(let task), .doneTask(let task):
                return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
            }
        }
    }
}
