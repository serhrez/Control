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
    
    private let bag = DisposeBag()
    private(set) var tags: [RlmTag] = []
    private let modelsUpdateSubject = PublishSubject<Void>()
    private var tokens: [NotificationToken] = []
    private var isInAdding: Bool = false
    private(set) var selectionSet: Set<RlmTag>
    private let mode: AllTagsVc.Mode
    
    // MARK: Outputs
    lazy var modelsUpdate: Observable<[AnimSection<Model>]> = modelsUpdateSubject.compactMap { [weak self] in self?.models }.share(replay: 1, scope: .whileConnected)
    var models: [AnimSection<Model>] {
        var models = ModelFormatt.tagsSorted(tags: tags).map { Model.tag($0) }
        if isInAdding {
            models.append(.addTagEnterName)
        } else {
            models.append(.addTag)
        }
        return [AnimSection(items: models)]
    }


    init(mode: AllTagsVc.Mode) {
        self.mode = mode
        switch mode {
        case let .selection(selected: selected, _):
            selectionSet = .init(selected)
        case .show:
            selectionSet = .init()
        }
        modelsUpdate.subscribe().disposed(by: bag)
        let tagsToken = RealmProvider.main.realm.objects(RlmTag.self).observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: dels, insertions: _, modifications: _):
                self.tags = Array(projects.sorted(byKeyPath: "createdAt"))
            case let .initial(projects):
                self.tags = Array(projects.sorted(byKeyPath: "createdAt"))
            case let .error(error):
                print(error)
            }
            self.modelsUpdateSubject.onNext(())
        }
        if case .show = mode { // Maybe we should use not only on show but who knows
            let tasksToken = RealmProvider.main.realm.objects(RlmTask.self).observe(on: .main) { [weak self] _ in
                self?.modelsUpdateSubject.onNext(())
            }
            tokens.append(tasksToken)
        }

        tokens.append(tagsToken)
    }

    func allTasksCount(for tag: RlmTag) -> Int {
        return RealmProvider.main.realm.objects(RlmTask.self).filter { $0.tags.contains(where: { $0.id == tag.id }) }.count
    }
    
    func allowAdding() {
        isInAdding = true
        self.modelsUpdateSubject.onNext(())
    }
    
    func addTag(name: String) {
        guard !name.isEmpty else { return }
        guard !RealmProvider.main.realm.objects(RlmTag.self).contains(where: { $0.name == name }) else { return }
        let tag = RlmTag(name: name)
        RealmProvider.main.safeWrite {
            RealmProvider.main.realm.add(tag)
        }
        isInAdding = false
        self.modelsUpdateSubject.onNext(())
        if case .selection = mode {
            selectionSet.insert(tag)
        }
    }
    func addTagClosedWithoutAdding() {
        isInAdding = false
        self.modelsUpdateSubject.onNext(())
    }
    
    func deleteTag(_ tag: RlmTag) {
        self.selectionSet.remove(tag)
        RealmProvider.main.safeWrite {
            RealmProvider.main.realm.cascadeDelete(tag)
        }
    }
        
    func changeTagInSelectionSet(tag: RlmTag, shouldBeInSet: Bool) {
        if shouldBeInSet {
            selectionSet.insert(tag)
        } else {
            selectionSet.remove(tag)
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
