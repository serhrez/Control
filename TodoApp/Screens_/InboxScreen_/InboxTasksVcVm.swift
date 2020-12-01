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
        let section1 = tasks.filter { !$0.isDone }.flatMap { [Model.task($0), Model.space(7)] }.dropLast()
        let section2 = tasks.filter { $0.isDone }.flatMap { [Model.doneTask($0), Model.space(7)] }.dropLast()
        let combinedItems = Array(section1.isEmpty ? section2 : section1 + [.space(45)] + section2)
        return [AnimSection(items: combinedItems)]
    }
    
    init() {
        modelsUpdate.subscribe().disposed(by: bag)
        let rlmProject = RealmProvider.main.realm.objects(RlmProject.self).filter { $0.name == "Inbox" }.first!
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
        case space(CGFloat)
        
        var identity: String {
            switch self {
            case .task(let task), .doneTask(let task):
                return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
            case .space:
                return UUID().uuidString
            }
        }
    }
}
