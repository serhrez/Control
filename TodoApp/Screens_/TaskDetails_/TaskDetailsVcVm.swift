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
            models.insert(.addSubtask, at: 0)
        }
        return [AnimSection(items: models)]
    }
    private var explicitAddSubtaskEnabled = false
    var reloadSubtaskCells: (_ modifications: [Int]) -> Void = { _ in }
    var shouldEnableTaskDescription: () -> Void = { }

    
    init(task: RlmTask) {
        self.task = task
        taskObservable.subscribe().disposed(by: bag)
        tagsObservable.subscribe().disposed(by: bag)
        subtasksUpdate.subscribe().disposed(by: bag)
        taskSubject.onNext(())

        let taskToken = task.observe { [weak self] _ in
            guard let self = self else { return }
            if task.isInvalidated {
                self.task = nil
                self.tokens = []
                return
            }
            if task.date == nil { self.dateToken = nil }
            self.listenToDate()
            self.taskSubject.onNext(())
        }
        let tagsToken = task.tags.observe { [weak self] _ in
            guard let self = self else { return }
            self.tagsSubject.onNext(())
        }
        let subtaskToken = task.subtask.observe { [weak self] changes in
            guard let self = self else { return }
            guard !(self.task?.isInvalidated ?? true) else { return }
            switch changes {
            case let .error(error):
                print(error)
            case .initial:
                self.subtasksUpdateSubject.onNext(())
            case let .update(_, deletions: _, insertions: _, modifications: mods):
                if !task.subtask.isEmpty {
                    self.explicitAddSubtaskEnabled = true
                }
                self.subtasksUpdateSubject.onNext(())
                self.reloadSubtaskCells(mods)
            }
        }
        listenToDate()
        tokens.append(contentsOf: [taskToken, tagsToken, subtaskToken])
    }
    private var timer: Timer?
    private var dateToken: NotificationToken?
    
    func addEmptyDescription() {
        shouldEnableTaskDescription()
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
    
    func selectNonePriority() {
        _ = try! RealmProvider.main.realm.write {
            task?.priority = .none
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
        dateToken = task?.date?.observe { [weak self] _ in
            guard let self = self else { return }
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
    
    func changeDescription(_ newDescription: String) {
        _ = try! RealmProvider.main.realm.write {
            task?.taskDescription = newDescription
        }
    }

    func changeName(_ newName: String) {
        _ = try! RealmProvider.main.realm.write {
            task?.name = newName
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
