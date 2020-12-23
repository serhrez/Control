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
import RxCocoa

class InboxTasksVcVm {
    private let bag = DisposeBag()
    private let modelsUpdateSubject = PublishSubject<Void>()
    private var tokens: [NotificationToken] = []
    private let tasks = PublishSubject<[RlmTask]>()
    lazy var tasksSharedObservable = tasks.asObservable().share(replay: 1, scope: .whileConnected)
    
    init() {
        tasksSharedObservable.subscribe().disposed(by: bag)
        let rlmProject = RealmProvider.main.realm.objects(RlmProject.self).filter { $0.name == "Inbox" }.first!
        let token = rlmProject.tasks.observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: _, insertions: _, modifications: _):
                self.tasks.onNext(Array(projects.sorted(byKeyPath: "createdAt")))
            case let .initial(projects):
                self.tasks.onNext(Array(projects.sorted(byKeyPath: "createdAt")))
            case let .error(error):
                print(error)
            }
            self.modelsUpdateSubject.onNext(())
        }
        tokens.append(token)
    }
}
