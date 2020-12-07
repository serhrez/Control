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
    let searchResult = BehaviorRelay<[AnimSection<Model>]>(value: .init([.init(items: [])]))
    
    func search(_ str: String) {
        let tasks = RealmProvider.main.realm.objects(RlmTask.self).filter { $0.name.lowercased().contains(str.lowercased()) }
        searchResult.accept([.init(items: tasks.map { Model(task: $0) })])
    }
    
    func onTaskDone(_ task: RlmTask, isDone: Bool) {
        _ = try! RealmProvider.main.realm.write {
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