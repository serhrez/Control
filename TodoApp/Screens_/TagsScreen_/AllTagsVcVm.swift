//
//  AllTagsVcVm.swift
//  TodoApp
//
//  Created by sergey on 12.11.2020.
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift

class AllTagsVcVm {
    
    private(set) var tags: [RlmTag] = []
    private let modelsUpdateSubject = PublishSubject<Void>()
    var modelsUpdate: Observable<[AnimSection<Model>]> {
        modelsUpdateSubject.compactMap { [weak self] in self?.models }
    }

    var models: [AnimSection<Model>] {
        var models = tags.map { Model.tag($0) }
        if isInAdding {
            models.append(.addTagEnterName)
        } else {
            models.append(.addTag)
        }
        return [AnimSection(items: models)]
    }
    private var tokens: [NotificationToken] = []
    private var isInAdding: Bool = false

    init() {
        PredefinedRealm.populateRealm(RealmProvider.inMemory.realm)
        let token = RealmProvider.inMemory.realm.objects(RlmTag.self).observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: _, insertions: _, modifications: _):
                self.tags = Array(projects.sorted(byKeyPath: "createdAt"))
            case let .initial(projects):
                self.tags = Array(projects.sorted(byKeyPath: "createdAt"))
            case let .error(error):
                print(error)
            }
            self.modelsUpdateSubject.onNext(())
        }
        tokens.append(token)
    }

    func allTasksCount(for tag: RlmTag) -> Int {
        return RealmProvider.inMemory.realm.objects(RlmTask.self).filter { $0.tags.contains(where: { $0.id == tag.id }) }.count
    }
    
    func allowAdding() {
        isInAdding = true
        self.modelsUpdateSubject.onNext(())
    }
    
    func addTag(name: String) {
        try! RealmProvider.inMemory.realm.write {
            RealmProvider.inMemory.realm.add(RlmTag(name: name))
        }
        isInAdding = false
        self.modelsUpdateSubject.onNext(())
    }
    
    func deleteTag(_ tag: RlmTag) {
        try! RealmProvider.inMemory.realm.write {
            RealmProvider.inMemory.realm.delete(tag)
        }
    }
}

extension AllTagsVcVm {
    enum Model: IdentifiableType, Equatable {
        case tag(RlmTag)
        case addTagEnterName
        case addTag
        
        var identity: String {
            switch self {
            case let .tag(rlmTag):
                return rlmTag.isInvalidated ? "deleted-\(UUID().uuidString)" : rlmTag.id
            case .addTagEnterName:
                return "addTag"
            case .addTag:
                return "addTag"
            }
        }
    }
}
