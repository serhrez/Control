//
//  PredefinedProjectVc.swift
//  TodoApp
//
//  Created by sergey on 07.01.2021.
//

import Foundation
import UIKit
import RxSwift
import RealmSwift
import Typist
import PopMenu
import SwiftDate

class PredefinedProjectVc: UIViewController {
    private let mode: Mode
    private let bag = DisposeBag()
    private var tokens = [NotificationToken]()
    private let tasksSubject = PublishSubject<[RlmTask]>()
    private let keyboard = Typist()
    private var addTaskModel: ProjectDetailsTaskCreateModel? {
        didSet {
            if oldValue == nil && addTaskModel != nil {
                changeState(isAdding: true)
            }
            if oldValue != nil && addTaskModel == nil {
                changeState(isAdding: false)
            }
            if let addTaskModel = addTaskModel {
                newFormView.priority = addTaskModel.priority
                newFormView.date = (addTaskModel.date, addTaskModel.reminder, addTaskModel.repeatt)
                newFormView.tags = ModelFormatt.tagsSorted(tags: addTaskModel.tags)
                newFormView.name = addTaskModel.name
                newFormView.taskDescriptionText = addTaskModel.description
            }
        }
    }
    private var didAppear = false
    lazy var tasksWithDoneList = TasksWithDoneList(onSelected: { [weak self] task in
        guard let self = self else { return }
        self.router.openTaskDetails(task)
    }, onChangeIsDone: { task in
        RealmProvider.main.safeWrite {
            task.isDone.toggle()
        }
    }, shouldDelete: { [weak self] task in
        guard let self = self,
              let project = task.project.first else { return }
        let taskId = task.id
        DBHelper.safeArchive(taskId: taskId, projectId: project.id)
        self.showBottomMessage(type: .taskDeleted) {
            DBHelper.safeUnarchive(taskId: taskId)
        }
    }, isGradientHidden: false)
    
    private lazy var newFormView = ProjectNewTaskForm(
        onCalendarClicked: { [weak self] _ in
            guard let self = self else { return }
            guard var addTask = self.addTaskModel else { return }
            guard UserDefaultsWrapper.shared.isPremium || RealmProvider.main.realm.objects(RlmTaskDate.self).count <= Constants.maximumDatesToTask else {
                self.router.openPremiumFeatures(notification: .dateToTaskLimit)
                return
            }
            self.dismiss(animated: true, completion: { [weak self] in
                Notifications.shared.requestAuthorization { authorization in
                    DispatchQueue.main.async {
                        switch authorization {
                        case .authorized:
                            self?.router.openDateVc(reminder: addTask.reminder, repeat: addTask.repeatt, date: addTask.date) { [weak self] (date, reminder, repeatt) in
                                addTask.date = date
                                addTask.reminder = reminder
                                addTask.repeatt = repeatt
                                self?.addTaskModel = addTask
                            }
                        case .denied:
                            print("Denied")
                        case .deniedPreviously:
                            self?.showAlertToOpenSettings()
                        }
                    }
                }
            })
        },
        onTagClicked: { [weak self] sourceView in
            guard let self = self else { return }
            guard var addTask = self.addTaskModel else { return }
            let prevFirstResponder = self.getFirstResponder()
            let allTags = Array(RealmProvider.main.realm.objects(RlmTag.self))
                .map { $0.name }
                .filter { !addTask.tags.contains($0) }
            let tagPicker = TagPicker(
                viewSource: sourceView,
                items: allTags,
                shouldPurposelyAnimateViewBackgroundColor: true,
                shouldDismiss: { tagPicker in
                    tagPicker.addChildDismiss()
                    prevFirstResponder?.becomeFirstResponder()
                },
                finished: { result in
                    switch result {
                    case let .existed(tagName) where !addTask.tags.contains(tagName):
                        addTask.tags.append(tagName)
                        self.addTaskModel = addTask
                    case let .new(tagName) where !addTask.tags.contains(tagName):
                        addTask.tags.append(tagName)
                        self.addTaskModel = addTask
                        if !RealmProvider.main.realm.objects(RlmTag.self).contains(where: { $0.name == tagName }) {
                            RealmProvider.main.safeWrite {
                                RealmProvider.main.realm.add(RlmTag(name: tagName))
                            }
                        }
                    default: break
                    }
                })
            self.addChildPresent(tagPicker)
            tagPicker.becomeFirstResponder()
        },
        onPriorityClicked: { [weak self] sourceView in
            guard UserDefaultsWrapper.shared.isPremium || RealmProvider.main.realm.objects(RlmTask.self).filter({ $0.priority != .none }).count <= Constants.maximumPriorities else {
                self?.router.openPremiumFeatures(notification: .prioritiesLimit)
                return
            }
            self?.showPriorityPicker(sourceView: sourceView)
        },
        onTagPlusClicked: { [weak self] in
            guard let self = self else { return }
            guard var addTask = self.addTaskModel else { return }
            let tags = RealmProvider.main.realm.objects(RlmTag.self).filter { tag in addTask.tags.contains(where: { $0 == tag.name }) }
            self.router.openAllTags(mode: .selection(selected: Array(tags), { [weak self] selected in
                addTask.tags = ModelFormatt.tagsSorted(tags: selected).map { $0.name }
                self?.addTaskModel = addTask
            }))
        },
        shouldAnimate: { [weak self] in
            self?.didAppear ?? false
        },
        shouldCreateTask: { [weak self] taskModel in
            self?.shouldCreateTask(task: taskModel)
        })
    private let newFormViewBg: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TABackground")!.withAlphaComponent(0.5)
        return view
    }()
    private let projectStartedView = ProjectStartedView(mode: .freeDay)
    private lazy var tasksToolbar = AllTasksToolbar()
    let trashTextField = TrashTextField()

    
    init(_ mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "TABackground")
        switch mode {
        case .priority:
            title = "Priority"
            projectStartedView.configure(tintColor: .hex("#447bfe"), mode: .noPriorities)
        case .today:
            title = "Today"
            projectStartedView.configure(tintColor: .hex("#ff9900"), mode: .freeDay)
        }
        tasksSubject.subscribe(onNext: { [weak self] tasks in
            self?.changeProjectStartedViewState(with: tasks.isEmpty)
        })
        .disposed(by: bag)
        tasksWithDoneList.sortingEnabled = false
        view.layout(projectStartedView).topSafe(0.065 * UIScreen.main.bounds.height).leading(47).trailing(47)
        applySharedNavigationBarAppearance()
        view.layout(tasksWithDoneList).topSafe().leading(13).trailing(13).bottom()
        setupTasksWithDoneListBinding()
        self.view.addSubview(trashTextField)
        toolbarViewSetup()
        projectNewTaskViewSetup()
        self.changeState(isAdding: false)
        setupKeyboard()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        newFormView.didAppear()
    }
    
    func setupTasksWithDoneListBinding() {
        tasksSubject
            .bind(to: tasksWithDoneList.itemsInput)
            .disposed(by: bag)
        let token = RealmProvider.main.realm.objects(RlmTask.self).observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .error(error):
                print(error)
            case let .initial(results), let .update(results, deletions: _, insertions: _, modifications: _):
                switch self.mode {
                case .priority:
                    self.tasksSubject.onNext(PredefinedProjectVc.sortPriority(results.filter { $0.priority != .none }))
                case .today:
                    self.tasksSubject.onNext(PredefinedProjectVc.sortToday(results.filter { $0.date?.date?.isToday ?? false }))
                }
            }
        }
        tokens.append(token)
    }
    private static func sortPriority(_ models: [RlmTask]) -> [RlmTask] {
        return models.sorted { task1, task2 -> Bool in
            if task1.isDone != task2.isDone {
                return task2.isDone
            }
            if task1.priority != task2.priority {
                return task1.priority > task2.priority
            }
            if task1.date?.date != nil && task2.date!.date != nil {
                return task1.date!.date! > task2.date!.date!
            }
            return task1.createdAt > task2.createdAt
        }
    }
    
    private static func sortToday(_ models: [RlmTask]) -> [RlmTask] {
        return models.sorted { task1, task2 -> Bool in
            if task1.isDone != task2.isDone {
                return task2.isDone
            }
            if task1.date?.date != nil && task2.date!.date != nil {
                return task1.date!.date! > task2.date!.date!
            }
            return task1.createdAt > task2.createdAt
        }
    }

    
    func showBottomMessage(type: BottomMessage.MessageType, onClicked: @escaping () -> Void) {
        let bottomMessage = BottomMessage.create(messageType: type, onClicked: onClicked)
        view.addSubview(bottomMessage)
        let height: CGFloat = !self.tasksToolbar.isHidden ?
            view.frame.height - tasksToolbar.frame.minY + 30 :
            self.view.safeAreaInsets.bottom + 15
        bottomMessage.show(height)
    }
    
    private func projectNewTaskViewSetup() {
        view.layout(newFormViewBg).edges()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newFormViewBgTapped))
        newFormViewBg.addGestureRecognizer(tapGesture)
        view.layout(newFormView).leading().trailing().topSafe(30) { _, _ in .greaterThanOrEqual }
        newFormView.shouldLayoutSubviews = { [weak self] in
            self?.view.layoutSubviews()
        }
        newFormView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    @objc func newFormViewBgTapped() {
        addTaskModel = nil
    }
    
    func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [weak self] options in
                guard let self = self else { return }
                let height = options.endFrame.intersection(self.view.bounds).height
                guard previousHeight != height else { return }
                if self.addTaskModel != nil && height < 100 { return }
                previousHeight = height
                self.newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                self.animateLayoutSubviews()
            }
            .on(event: .willHide) { [weak self] options in
                guard let self = self else { return }
                let height = options.endFrame.intersection(self.view.bounds).height
                guard previousHeight != height else { return }
                if self.addTaskModel != nil && height < 100 { return }
                previousHeight = height
                self.newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                self.animateLayoutSubviews()
            }
            .start()
    }

    private func animateLayoutSubviews() {
        if didAppear {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                self.view.layoutSubviews()
            }
        }
    }
    
    func getFirstResponder() -> UIView? {
        if let firstResponder = newFormView.getFirstResponder() {
            return firstResponder
        }
        return nil
    }
    
    private func toolbarViewSetup() {
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(Constants.vcMinBottomPadding)
        tasksToolbar.onClick = { [weak self] in
            self?.setUpInitialDataToAddTaskModel()
        }
    }
    
    func setUpInitialDataToAddTaskModel() {
        switch self.mode {
        case .priority:
            let shouldAddPriority = RealmProvider.main.realm.objects(RlmTask.self).filter { $0.priority != Priority.none }.count <= Constants.maximumPriorities
            self.addTaskModel = .init(priority: shouldAddPriority ? .low : .none, name: "", description: "", tags: [], date: nil, reminder: nil, repeatt: nil)
        case .today:
            let threeHoursLaterDate = Date().dateAtEndOf(.hour) + 1.seconds + 2.hours
            let date = threeHoursLaterDate.isToday ? threeHoursLaterDate : Date()
            let shouldAddDate = UserDefaultsWrapper.shared.isPremium || RealmProvider.main.realm.objects(RlmTaskDate.self).count <= Constants.maximumDatesToTask
            self.addTaskModel = .init(priority: .none, name: "", description: "", tags: [], date: shouldAddDate ? date : nil , reminder: nil, repeatt: nil)
        }
    }
    
    func changeProjectStartedViewState(with isEmpty: Bool) {
        func apply() {
            self.projectStartedView.alpha = isEmpty ? 1 : 0
        }
        if didAppear {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                apply()
            }
        } else {
            apply()
        }
    }

    func changeState(isAdding: Bool = false) {
        if isAdding {
            _ = newFormView.becomeFirstResponder()
        } else {
            newFormView.getFirstResponder()?.resignFirstResponder()
        }
        func apply() {
            self.newFormView.alpha = isAdding ? 1 : 0
            self.newFormViewBg.alpha = isAdding ? 1 : 0
            self.projectStartedView.alpha = isAdding ? 0 : (self.tasksWithDoneList.isEmpty ? 1 : 0)
        }
        if didAppear {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                apply()
            }
        } else {
            apply()
        }
    }

    private func showAlertToOpenSettings() {
        let alertController = UIAlertController(title: "Notifications are disabled", message: "You disabled notification for this app, so we cannot set up notifications", preferredStyle: .alert)
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            guard UIApplication.shared.canOpenURL(settingsUrl) else { return }
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ -> Void in
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
        } else {
            let cancelAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertController.addAction(cancelAction)
        }

        present(alertController, animated: true, completion: nil)
    }
    
    func showPriorityPicker(sourceView: UIView) {
        let prevFirstResponder = self.getFirstResponder()
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "High Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.addTaskModel else { return }
                                addTask.priority = .high
                                self?.addTaskModel = addTask
                            }),
            PopuptodoAction(title: "Medium Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.addTaskModel else { return }
                                addTask.priority = .medium
                                self?.addTaskModel = addTask
                            }),
            PopuptodoAction(title: "Low Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.addTaskModel else { return }
                                addTask.priority = .low
                                self?.addTaskModel = addTask
                            }),
            PopuptodoAction(title: "No Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.addTaskModel else { return }
                                addTask.priority = .none
                                self?.addTaskModel = addTask
                            })
        ]
        actions[0].imageTintColor = .hex("#EF4439")
        actions[1].imageTintColor = .hex("#FF9900")
        actions[2].imageTintColor = .hex("#447BFE")
        actions[3].imageTintColor = UIColor(named: "TASubElement")!
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: sourceView, actions: actions)
        popMenu.appearance = .appAppearance
        popMenu.isCrutchySolution1 = true
        popMenu.view.layer.opacity = 0
        addChildPresent(popMenu)
        trashTextField.becomeFirstResponder()
        UIView.animate(withDuration: 0.2) {
            popMenu.view.layer.opacity = 1
        }
        popMenu.didDismiss = { [weak popMenu] _ in
            UIView.animate(withDuration: 0.2) {
                popMenu?.view.layer.opacity = 0
            } completion: { _ in
                popMenu?.addChildDismiss()
                prevFirstResponder?.becomeFirstResponder()
            }
        }
    }
    
    func shouldCreateTask(task: ProjectDetailsTaskCreateModel) {
        guard let project = RealmProvider.main.realm.objects(RlmProject.self).filter({ $0.id == Constants.inboxId }).first else { return }
        let rlmTags = RealmProvider.main.realm.objects(RlmTag.self).filter { tag in task.tags.contains(where: { tag.name == $0 }) }
        let rlmTask = RlmTask(name: task.name, taskDescription: task.description, priority: task.priority, isDone: false, date: RlmTaskDate(date: task.date, reminder: task.reminder, repeat: task.repeatt), createdAt: Date())
        rlmTask.tags.append(objectsIn: rlmTags)
        RealmProvider.main.safeWrite {
            project.tasks.append(rlmTask)
        }
        var shouldClose = false
        switch self.mode {
        case .priority:
            if task.priority == .none {
                showBottomMessage(type: .taskCreatedInInbox, onClicked: { })
                shouldClose = true
            }
        case .today:
            if task.date == nil || task.date.flatMap { !$0.isToday } ?? false {
                showBottomMessage(type: .taskCreatedInInbox, onClicked: { })
                shouldClose = true
            }
        }
        if shouldClose {
            addTaskModel = nil
            newFormView.resetView()
        } else {
            setUpInitialDataToAddTaskModel()
        }
    }


}

extension PredefinedProjectVc {
    enum Mode {
        case today
        case priority
    }
}
