//
//  CreateProjectVcVm.swift
//  TodoApp
//
//  Created by sergey on 29.11.2020.
//

import Foundation
import RxSwift
import RealmSwift
import RxDataSources
import RxCocoa

class CreateProjectVcVm {
    var project: RlmProject?
    private let bag = DisposeBag()
    private var tokens = [NotificationToken]()
    private let updateTasks = PublishSubject<Void>()
    private var addTask: RlmTask = RlmTask()
    private var taskInFocus: RlmTask?
    private let afterReloadTaskCells = PublishSubject<Void>()
    var taskToAddComponents: RlmTask {
        taskInFocus ?? addTask
    }
    var bringFocusToTagsAtIndex: (Int) -> Void = { _ in }
    var bringFocusToTextField: (Int) -> Void = { _ in }
    let tasksUpdate = BehaviorRelay<[AnimSection<Model>]>(value: [.init(items: [])])
    private var tasksAllowedToHaveTags = Set<RlmTask>()

    var tasksModel: [AnimSection<Model>] {
        var models = Array(project?.tasks.map { Model(task: $0, isTagsAllowed: tasksAllowedToHaveTags.contains($0), mode: .task) } ?? [] )
        models += [Model(task: addTask, isTagsAllowed: tasksAllowedToHaveTags.contains(addTask), mode: .addTask)]
        return [AnimSection(items: models)]
    }
    var reloadTasksCells: (_ modifications: [Int]) -> Void = { _ in }
    
    convenience init() {
        let project = RlmProject()
        _ = try! RealmProvider.main.realm.write {
            RealmProvider.main.realm.add(project)
        }
        self.init(project: project)
    }
    
    init(project: RlmProject) {
        self.project = project
        updateTasks.subscribe(onNext: { [unowned self] in self.tasksUpdate.accept(self.tasksModel) }).disposed(by: bag)
        updateTasks.onNext(())
        let tasksToken = project.tasks.observe { [unowned self] changes in
            switch changes {
            case let .error(error):
                print(error)
            case .initial:
                updateTasks.onNext(())
            case .update(_, deletions: _, insertions: _, modifications: let mods):
                updateTasks.onNext(())
                if !mods.isEmpty {
                    reloadTasksCells(mods)
                }
                afterReloadTaskCells.onNext(())
            }
        }
        tokens.append(contentsOf: [tasksToken])
        _ = try! RealmProvider.main.realm.write {
            ["Task1", "Task2", "Task1", "Task2", "Task1", "Task2", "Task1", "Task2", "Task1", "Task2", "Task1", "Task2", "Task1", "Task2", "Task1", "Task2", "Task1", "Task2", "Task2", "Task1", "Task2", "Task1", "Task2", "Task1", "Task2"].forEach {
                self.project?.tasks.append(.init(name: $0, isDone: Int.random(in: 1...2) == 1))
            }
        }
    }
    
    func tagAdded(with name: String, to task: RlmTask) {
        guard !task.tags.contains(where: { $0.name == name }) else { return }
        afterReloadTaskCells.take(1).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.project?.tasks.firstIndex(where: { $0.id == task.id }).flatMap { self.bringFocusToTagsAtIndex($0) }
        })
        .disposed(by: bag)
        if let tag = RealmProvider.main.realm.objects(RlmTag.self).filter({ $0.name == name }).first,
           !task.tags.contains(tag) {
            _ = try! RealmProvider.main.realm.write {
                task.tags.append(tag)
            }
            return
        }
        let tag = RlmTag(name: name)
        _ = try! RealmProvider.main.realm.write {
            task.tags.append(tag)
        }
    }
    func tagDeleted(with name: String, from task: RlmTask) {
        if let tagIndex = task.tags.firstIndex(where: { $0.name == name }) {
            _ = try! RealmProvider.main.realm.write {
                task.tags.remove(at: tagIndex)
            }
        }
    }
    
    func taskNameChanged(task: RlmTask, name: String) {
        _ = try! RealmProvider.main.realm.write(withoutNotifying: tokens) {
            task.name = name
        }
    }
    
    func changeIsDone(task: RlmTask, isDone: Bool) {
        _ = try! RealmProvider.main.realm.write(withoutNotifying: tokens) {
            task.isDone = isDone
        }
    }
    
    func taskCreated(_ task: RlmTask) {
        afterReloadTaskCells.take(1).subscribe(onNext: { [unowned self] in
            tasksModel[0].items.firstIndex(where: { $0.task.id == addTask.id }).flatMap { bringFocusToTextField($0) }
        })
        .disposed(by: bag)
        if project?.tasks.contains(task) ?? true { return }
        addTask = RlmTask()
        _ = try! RealmProvider.main.realm.write {
            project?.tasks.append(task)
        }
    }
    
    func setTagAllowed(to task: RlmTask) {
        guard task.tags.isEmpty && !tasksAllowedToHaveTags.contains(task) else { return }
        if task == addTask {
            tasksAllowedToHaveTags.insert(task)
            taskCreated(addTask)
            afterReloadTaskCells
                .take(1)
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.project?.tasks.firstIndex(where: { $0.id == task.id }).flatMap { self.bringFocusToTagsAtIndex($0) }
                })
                .disposed(by: bag)
        } else
        if let taskIndex = tasksModel[0].items.firstIndex(where: { task.id == $0.task.id }) {
            tasksAllowedToHaveTags.insert(task)
            updateTasks.onNext(())
            reloadTasksCells([taskIndex])
            project?.tasks.firstIndex(where: { $0.id == task.id }).flatMap { bringFocusToTagsAtIndex($0) }
        }
    }
    
    func setDate(to task: RlmTask, date: (Date?, Reminder?, Repeat?)) {
        _ = try! RealmProvider.main.realm.write {
            task.date = RlmTaskDate(date: date.0, reminder: date.1, repeat: date.2)
        }
        if task == addTask { taskCreated(addTask) }
    }
    
    func onFocusChanged(to task: RlmTask?) {
        taskInFocus = task
    }
    
    func shouldDelete(_ task: RlmTask) {
        if let taskIndex = project?.tasks.firstIndex(where: { $0.id == task.id }) {
            _ = try! RealmProvider.main.realm.write {
                project?.tasks.remove(at: taskIndex)
            }
        }
    }
    
    func selectPriority(to task: RlmTask, priority: Priority) {
        
    }

}

extension CreateProjectVcVm {
    struct Model: IdentifiableType, Equatable {
        var task: RlmTask
        var isTagsAllowed: Bool
        var mode: Mode
        enum Mode {
            case task
            case addTask
        }
        var identity: String {
            return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
        }
    }
}
