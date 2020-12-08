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
    var taskToAddComponents: RlmTask {
        taskInFocus ?? addTask
    }
    let tasksUpdate = BehaviorRelay<[AnimSection<Model>]>(value: [.init(items: [])])
    private var tasksAllowedToHaveTags = Set<RlmTask>()

    var tasksModel: [AnimSection<Model>] {
        let models = Array(project?.tasks.map { Model.task($0, tasksAllowedToHaveTags.contains($0)) } ?? [] ) + [.addTask(addTask, tasksAllowedToHaveTags.contains(addTask))]
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
            }
        }
        tokens.append(contentsOf: [tasksToken])
    }
    
    func tagAdded(with name: String, to task: RlmTask) {
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
        if let tagIndex = RealmProvider.main.realm.objects(RlmTag.self).firstIndex(where: { $0.name == name }) {
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
        if project?.tasks.contains(task) ?? true { return }
        _ = try! RealmProvider.main.realm.write {
            project?.tasks.append(task)
        }
        addTask = RlmTask()
    }
    
    func setTagAllowed(to task: RlmTask) {
        if task == addTask {
            tasksAllowedToHaveTags.insert(task)
            taskCreated(addTask)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//
//            }
        } else
        if let taskIndex = tasksModel[0].items.firstIndex(where: {
            switch $0 {
            case let .addTask(xtask, _):
                return task.id == xtask.id
            case let .task(xtask, _):
                return task.id == xtask.id
            }
        }) {
            tasksAllowedToHaveTags.insert(task)
            updateTasks.onNext(())
            reloadTasksCells([taskIndex])
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
        print("switched to: \(task)")
    }
    
    func shouldDelete(_ task: RlmTask) {
        if let taskIndex = project?.tasks.firstIndex(where: { $0.id == task.id }) {
            _ = try! RealmProvider.main.realm.write {
                project?.tasks.remove(at: taskIndex)
            }
        }
    }
}

extension CreateProjectVcVm {
    enum Model: IdentifiableType, Equatable {
        case task(RlmTask, Bool)
        case addTask(RlmTask, Bool)
        
        var identity: String {
            switch self {
            case let .task(task, _), let .addTask(task, _):
                return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
            }
        }
    }
}
