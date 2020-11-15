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

enum Models: IdentifiableType, Equatable {
    case tag(RlmTag)
    case addTagEnterName
    case addTag(Bool)
    
    var identity: String {
        switch self {
        case let .tag(rlmTag):
            return rlmTag.isInvalidated ? "deleted-\(UUID().uuidString)" : rlmTag.id
        case .addTagEnterName:
            return "addTagEnterName"
        case .addTag:
            return "addTag"
        }
    }
}
struct SectionOfCustomData: AnimatableSectionModelType, IdentifiableType {
    
    init(original: SectionOfCustomData, items: [Models]) {
        self = original
        self.items = items
    }
    
    init(header: String, items: [Models]) {
        self.header = header
        self.items = items
    }
    
    var header: String
    var items: [Models]
    
    var identity: String { "sect1" }
}


class AllTagsVcVm {
    
    typealias TableUpdatesFunc = (_ deletions: [Int], _ insertions: [Int], _ modifications: [Int]) -> Void
    private(set) var tags: [(RlmTag, String?)] = []
    var models: [SectionOfCustomData] {
        var models = tags.map { Models.tag($0.0) }
        if isInAdding {
            models.append(.addTagEnterName)
        }
        models.append(.addTag(!isInAdding))
        return [SectionOfCustomData(header: "", items: models)]
    }
    let modelsq = PublishSubject<[SectionOfCustomData]>()
    private var tokens: [NotificationToken] = []
    var tableUpdates: TableUpdatesFunc?
    var initialValues: (() -> Void)?
    var isInAdding: Bool = false

    init() {
        PredefinedRealm.populateRealm(RealmProvider.inMemory.realm)
        let token = RealmProvider.inMemory.realm.objects(RlmTag.self).observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: deletions, insertions: insertions, modifications: modifications):
                self.tags = Array(projects.sorted(byKeyPath: "createdAt")).map { ($0, nil) }
                if !insertions.isEmpty {
                    self.tags[insertions[0]] = (self.tags[insertions[0]].0, "addTagEnterName")
                }
                self.tableUpdates?(deletions, insertions, modifications)
            case let .initial(projects):
                self.tags = Array(projects.sorted(byKeyPath: "createdAt")).map { ($0, nil) }
                self.initialValues?()
            case let .error(error):
                print(error)
            }
            self.modelsq.onNext(self.models)
        }
        tokens.append(token)
    }

    func allTasksCount(for tag: RlmTag) -> Int {
        return RealmProvider.inMemory.realm.objects(RlmTask.self).filter { $0.tags.contains(where: { $0.id == tag.id }) }.count
    }
    
    func allowAdding(bool: Bool = true) {
        isInAdding = bool
        self.modelsq.onNext(self.models)
    }
    
    func deleteItem(tag: RlmTag) {
        try! RealmProvider.inMemory.realm.write {
            RealmProvider.inMemory.realm.delete(tag)
        }
    }
}
