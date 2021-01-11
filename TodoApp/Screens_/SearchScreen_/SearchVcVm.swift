//
//  SearchVcVm.swift
//  TodoApp
//
//  Created by sergey on 28.11.2020.
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift
import RxCocoa

class SearchVcVm {
    private let bag = DisposeBag()
    private var notificationTokens = [NotificationToken]()
    let searchResult = BehaviorRelay<[AnimSection<Model>]>(value: .init([.init(items: [])]))
    var lastSearchedText: String?
    init() {
        let tasksToken = RealmProvider.main.realm.objects(RlmTask.self).observe(on: .main) { [weak self] changes in
            switch changes {
            case let .error(error): print(error)
            case .initial: break
            case .update:
                if let lastSearchedText = self?.lastSearchedText {
                    self?.search(lastSearchedText)
                } else {
                    self?.allTasksPopulate()
                }
            }
        }
        notificationTokens.append(tasksToken)
        allTasksPopulate()
    }
    
    private func allTasksPopulate() {
        let allTasks = RealmProvider.main.realm.objects(RlmTask.self)
        searchResult.accept([.init(items: allTasks.map { Model(task: $0) })])
    }
    func search(_ str: String) {
        lastSearchedText = str
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let tasksIds = Array(RealmProvider.main.realm.objects(RlmTask.self).filter { $0.name.lowercased().contains(str.lowercased()) }.map { $0.id })
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.lastSearchedText == str {
                    let tasks = RealmProvider.main.realm.objects(RlmTask.self).filter { tasksIds.contains($0.id) }
                    self.searchResult.accept([.init(items: tasks.map { Model(task: $0) })])
                }
            }
        }
    }
    
    func onTaskDone(_ task: RlmTask, isDone: Bool) {
        RealmProvider.main.safeWrite {
            task.isDone = isDone
        }
    }
    func clear() {
        searchResult.accept([.init(items: [])])
    }
}

extension SearchVcVm {
    struct Model: IdentifiableType, Equatable {
        var task: RlmTask
        
        var identity: String {
            return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
        }
    }
}
