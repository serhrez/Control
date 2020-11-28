//
//  TaskDetailsVcVm.swift
//  TodoApp
//
//  Created by sergey on 18.11.2020.
//

import Foundation
import RxSwift
import RealmSwift
import RxDataSources

class TaskDetailsVcVm {
    var task: RlmTask?
    private let bag = DisposeBag()
    private var tokens: [NotificationToken] = []

    private let taskSubject = PublishSubject<Void>()
    lazy var taskObservable: Observable<RlmTask> = taskSubject.compactMap { [weak self] in self?.task }.share(replay: 1, scope: .whileConnected)
    
    private let tagsSubject = PublishSubject<Void>()
    lazy var tagsObservable: Observable<Void> = tagsSubject.share(replay: 1, scope: .whileConnected)
    
    private let subtasksUpdateSubject = PublishSubject<Void>()
    lazy var subtasksUpdate = subtasksUpdateSubject.compactMap { [weak self] in self?.subtasksModels }.share(replay: 1, scope: .whileConnected)
    var subtasksModels: [AnimSection<Model>] {
        var models = Array(task?.subtask.map { Model.subtask($0) } ?? [])
        if !models.isEmpty || explicitAddSubtaskEnabled {
            models.append(.addSubtask)
        }
        return [AnimSection(items: models)]
    }
    private var explicitAddSubtaskEnabled = false
    var reloadSubtaskCells: (_ modifications: [Int]) -> Void = { _ in }

    
    init(task: RlmTask) {
        self.task = task
        taskObservable.subscribe().disposed(by: bag)
        tagsObservable.subscribe().disposed(by: bag)
        subtasksUpdate.subscribe().disposed(by: bag)
        taskSubject.onNext(())

        let taskToken = task.observe { [unowned self] _ in
            if task.date == nil { dateToken = nil }
            listenToDate()
            taskSubject.onNext(())
        }
        let tagsToken = task.tags.observe { [unowned self] _ in            
            tagsSubject.onNext(())
        }
        let subtaskToken = task.subtask.observe { [unowned self] changes in
            switch changes {
            case let .error(error):
                print(error)
            case .initial:
                subtasksUpdateSubject.onNext(())
            case let .update(_, deletions: _, insertions: _, modifications: mods):
                if !task.subtask.isEmpty {
                    explicitAddSubtaskEnabled = false
                }
                subtasksUpdateSubject.onNext(())
                reloadSubtaskCells(mods)
            }
        }
        listenToDate()
        tokens.append(contentsOf: [taskToken, tagsToken, subtaskToken])
    }
    private var timer: Timer?
    private var dateToken: NotificationToken?
    
    func addEmptyDescription() {
        _ = try! RealmProvider.main.realm.write {
            task?.taskDescription = "Emptyxpk"
        }
    }
    
    func addTags(_ tags: [RlmTag]) {
        guard let task = task else { return }
        _ = try! RealmProvider.main.realm.write {
            task.tags.replaceSubrange(task.tags.startIndex..<task.tags.endIndex, with: tags)
        }
    }
    
    func explicitlyEnableTableView() {
        explicitAddSubtaskEnabled = true
        subtasksUpdateSubject.onNext(())
    }
    
    func selectHighPriority() {
        _ = try! RealmProvider.main.realm.write {
            task?.priority = .high
        }
    }
    
    func selectMediumPriority() {
        _ = try! RealmProvider.main.realm.write {
            task?.priority = .medium
        }
    }
    
    func selectLowPriority() {
        _ = try! RealmProvider.main.realm.write {
            task?.priority = .low
        }
    }
    
    func deleteItselfInRealm() {
        guard let task = self.task else { return }
        self.task = nil
        tokens.removeAll()
        dateToken = nil
        _ = try! RealmProvider.main.realm.write {
            RealmProvider.main.realm.delete(task)
        }
    }
    func listenToDate() {
        guard dateToken == nil else { return }
        dateToken = task?.date?.observe { [unowned self] _ in
            self.taskSubject.onNext(())
        }
    }
    func toggleDone() {
        _ = try! RealmProvider.main.realm.write { [weak self] in
            self?.task?.isDone.toggle()
        }
    }
    
    func deleteTag(with title: String) {
        guard let tagIndex = task?.tags.firstIndex(where: { $0.name == title }) else {
            fatalError("We should've found it")
        }
        _ = try! RealmProvider.main.realm.write {
            task?.tags.remove(at: tagIndex)
        }
    }
        
    func createSubtask(with name: String) {
        _ = try! RealmProvider.main.realm.write {
            task?.subtask.append(RlmSubtask(name: name))
        }
    }
    
    func toggleDoneSubtask(subtask: RlmSubtask, isDone: Bool) {
        _ = try! RealmProvider.main.realm.write {
            subtask.isDone = isDone
        }
    }
    
    func deleteSubtask(subtask: RlmSubtask) {
        _ = try! RealmProvider.main.realm.write {
            RealmProvider.main.realm.delete(subtask)
        }
    }

}

extension TaskDetailsVcVm {
    enum Model: IdentifiableType, Equatable {
        case subtask(RlmSubtask)
        case addSubtask
        
        var identity: String {
            switch self {
            case let .subtask(rlmSubtask):
                return rlmSubtask.isInvalidated ? "deleted-\(UUID().uuidString)" : rlmSubtask.id + "\(rlmSubtask.isDone)"
            case .addSubtask:
                return "addSubtask"
            }
        }
    }
}
