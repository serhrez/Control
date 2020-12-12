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
    var projectPropertiesChanged: (RlmProject) -> Void = { _ in }
    var bringFocusToTagsAtIndex: (Int) -> Void = { _ in }
    var bringFocusToTextField: (Int) -> Void = { _ in }
    let tasksUpdate = BehaviorRelay<[AnimSection<Model>]>(value: [.init(items: [])])
    private var tasksAllowedToHaveTags = Set<RlmTask>()
    private let wasProjectCreatedAtPlace: Bool

    var tasksModel: [AnimSection<Model>] {
        var models = Array(project?.tasks.map { Model(task: $0, isTagsAllowed: tasksAllowedToHaveTags.contains($0), mode: .task) } ?? [] )
        models += [Model(task: addTask, isTagsAllowed: tasksAllowedToHaveTags.contains(addTask), mode: .addTask)]
        return [AnimSection(items: models.flatMap { [$0, .init(isEmptySpace: true, task: $0.task)] }.dropLast())]
    }
    var reloadTasksCells: (_ modifications: [Int]) -> Void = { _ in }
    
    convenience init() {
        let project = RlmProject()
        _ = try! RealmProvider.main.realm.write {
            RealmProvider.main.realm.add(project)
        }
        self.init(project: project, wasProjectCreatedAtPlace: true)
    }
    
    init(project: RlmProject, wasProjectCreatedAtPlace: Bool = false) {
        self.wasProjectCreatedAtPlace = wasProjectCreatedAtPlace
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
                    reloadTasksCells(mods.map { getNotRealRowIndex($0) })
                }
                afterReloadTaskCells.onNext(())
            }
        }
        let projectToken = project.observe { [unowned self] changes in
            projectPropertiesChanged(project)
        }
        tokens.append(contentsOf: [tasksToken, projectToken])
    }
    
    func setProjectColor(color: UIColor) {
        _ = try! RealmProvider.main.realm.write {
            project?.color = color
        }
    }
        
    func setProjectIcon(_ newIcon: Icon) {
        _ = try! RealmProvider.main.realm.write {
            project?.icon = newIcon
        }
    }
    
    func tagAdded(with name: String, to task: RlmTask) {
        guard !task.tags.contains(where: { $0.name == name }) else { return }
        afterReloadTaskCells.take(1).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.project?.tasks.firstIndex(where: { $0.id == task.id }).flatMap { self.bringFocusToTagsAtIndex(self.getNotRealRowIndex($0)) }
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
    
    func taskCreated(_ task: RlmTask, goToNewCellTextField: Bool = true) {
        if goToNewCellTextField {
        afterReloadTaskCells.take(1)
            .subscribe(onNext: { [unowned self] in
            tasksModel[0].items.firstIndex(where: { $0.task.id == addTask.id }).flatMap { bringFocusToTextField($0) }
        })
        .disposed(by: bag)
        }
        if project?.tasks.contains(task) ?? true { return }
        addTask = RlmTask()
        if task.name.isEmpty { task.name = "New To-Do" }
        
        _ = try! RealmProvider.main.realm.write {
            project?.tasks.append(task)
        }
    }
    
    func setTagAllowed(to task: RlmTask) {
        guard task.tags.isEmpty && !tasksAllowedToHaveTags.contains(task) else { return }
        if task == addTask {
            tasksAllowedToHaveTags.insert(task)
            taskCreated(addTask, goToNewCellTextField: false)
            afterReloadTaskCells
                .take(1)
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.project?.tasks.firstIndex(where: { $0.id == task.id }).flatMap { self.bringFocusToTagsAtIndex(self.getNotRealRowIndex($0)) }
                })
                .disposed(by: bag)
        } else
        if let taskIndex = tasksModel[0].items.firstIndex(where: { task.id == $0.task.id }) {
            tasksAllowedToHaveTags.insert(task)
            updateTasks.onNext(())
            reloadTasksCells([taskIndex])
            project?.tasks.firstIndex(where: { $0.id == task.id }).flatMap { bringFocusToTagsAtIndex(getNotRealRowIndex($0)) }
        }
    }
    
    func setDate(to task: RlmTask, date: (Date?, Reminder?, Repeat?)) {
        _ = try! RealmProvider.main.realm.write {
            task.date = RlmTaskDate(date: date.0, reminder: date.1, repeat: date.2)
        }
        if task == addTask { taskCreated(addTask, goToNewCellTextField: false) }
    }
    
    func onFocusChanged(to task: RlmTask?) {
        taskInFocus = task
    }
    
    func shouldDelete(_ task: RlmTask) {
        if let taskIndex = project?.tasks.firstIndex(where: { $0.id == task.id }) {
            _ = try! RealmProvider.main.realm.write {
                project?.tasks.remove(at: taskIndex)
            }
            if taskIndex > 0 && project != nil {
                onFocusChanged(to: project!.tasks[taskIndex - 1])
                bringFocusToTextField(getNotRealRowIndex(taskIndex - 1))
            }
        }
    }
    
    func selectPriority(to task: RlmTask, priority: Priority) {
        _ = try! RealmProvider.main.realm.write {
            task.priority = priority
        }
        if task == addTask { taskCreated(addTask) }
    }
    
    func getRealRowIndex(_ index: Int) -> Int {
        return index - index % 2
    }
    
    func getNotRealRowIndex(_ realIndex: Int) -> Int {
        return realIndex * 2
    }

}

extension CreateProjectVcVm {
    struct Model: IdentifiableType, Equatable {
        var isEmptySpace: Bool
        var task: RlmTask
        var isTagsAllowed: Bool
        var mode: Mode
        
        init(isEmptySpace: Bool, task: RlmTask) {
            self.isEmptySpace = true
            self.task = task
            self.isTagsAllowed = false
            self.mode = .addTask
        }
        
        init(task: RlmTask, isTagsAllowed: Bool, mode: Mode) {
            self.task = task
            self.isTagsAllowed = isTagsAllowed
            self.mode = mode
            self.isEmptySpace = false
        }
        enum Mode {
            case task
            case addTask
        }
        var identity: String {
            if isEmptySpace { return task.isInvalidated ? "deletedx-\(UUID().uuidString)" : task.id + "x" }
            return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
        }
    }
}
