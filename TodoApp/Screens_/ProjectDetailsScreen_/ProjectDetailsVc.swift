//
//  ProjectDetailsVc.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import Material
import Typist
import PopMenu
import RealmSwift
import RxSwift
import RxCocoa

class ProjectDetailsVc: UIViewController {
    var didAppear: Bool = false
    private let keyboard = Typist()
    private var _oldState: PrScreenState
    private var state: PrScreenState {
        didSet {
            changeState(oldState: _oldState, newState: state)
            _oldState = state
        }
    }
    @SafeObject private var project: RlmProject
    private var isInbox: Bool
    private var tokens: [NotificationToken] = []
    private let bag = DisposeBag()
    private let shouldPopTwo: Bool
    private var doOnAppear: (() -> Void)?
    let trashTextField = TrashTextField()
    init(project: RlmProject, state: PrScreenState, isInbox: Bool = false, shouldPopTwo: Bool = false) {
        self.project = project
        self.isInbox = isInbox
        self._oldState = state
        self.state = state
        self.shouldPopTwo = shouldPopTwo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "TABackground")
        projectBindingSetup()
        topViewSetup()
        projectStartedViewSetup()
        tasksWithDoneListSetup()
        toolbarViewSetup()
        setupKeyboard()
        projectNewTaskViewSetup()
        self.view.addSubview(trashTextField)
        let __updState = self.state
        self.state = __updState
        projectPropertiesChanged() // Init state
        applySharedNavigationBarAppearance(customOnBack: shouldPopTwo ? { [weak self] in
            self?.navigationController?.popViewControllers(2)
            } : nil, popGesture: !shouldPopTwo)
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldPopTwo {
            removeInteractivePopGesture()
        }
        didAppear = true
        self.newFormView.didAppear()
        self.view.layoutSubviews()
        doOnAppear?()
        doOnAppear = nil
    }
    
    func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [weak self] options in
                guard let self = self else { return }
                let height = options.endFrame.intersection(self.view.bounds).height
                guard previousHeight != height else { return }
                if self.state.isAddTask && height < 100 { return }
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
                if self.state.isAddTask && height < 100 { return }
                previousHeight = height
                self.newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                self.animateLayoutSubviews()
            }
            .start()
    }
    
    private func changeState(oldState: PrScreenState, newState: PrScreenState) {
        if case .emptyOrList = newState {
            state = project.tasks.isEmpty ? .empty : .list
            return
        }
        
        // Changing state
        var tasksToolBarOpacity: Float = 0
        var projectStartedViewOpacity: Float = 0
        var newFormViewBgOpacity: Float = 0
        var newFormViewOpacity: Float = 0
        var tasksWithDoneListOpacity: Float = 0
        // Pre change state
        switch (oldState, newState) {
        case (.addTask(_), _) where !newState.isAddTask:
            newFormView.getFirstResponder()?.resignFirstResponder()
        default: break
        }
        // Changing state
        switch (oldState, newState) {
        case (_, .startAddTask):
            doOnAppear = { [weak self] in
                self?._oldState = .list
                self?.state = .addTask(.init(priority: .none, name: "", description: "", tags: [], date: nil, reminder: nil, repeatt: nil))
            }
            tasksWithDoneListOpacity = 1
        case (.list, .addTask(_)):
            newFormViewBgOpacity = 1
            newFormViewOpacity = 1
            tasksWithDoneListOpacity = 1
            _ = self.newFormView.becomeFirstResponder()
        case (_, .addTask(_)) where !oldState.isAddTask:
            newFormViewBgOpacity = 1
            newFormViewOpacity = 1
            _ = self.newFormView.becomeFirstResponder()
        case let (.addTask(_), .addTask(newTask)):
            newFormView.priority = newTask.priority
            newFormView.date = (newTask.date, newTask.reminder, newTask.repeatt)
            newFormView.tags = ModelFormatt.tagsSorted(tags: newTask.tags)
            self.tasksWithDoneList.layer.opacity = 1
            return
        case (_, .list):
            tasksWithDoneListOpacity = 1
            tasksToolBarOpacity = 1
        case (_, .new):
            projectStartedViewOpacity = 1
            tasksToolBarOpacity = 1
        case (_, .empty):
            tasksToolBarOpacity = 1
            projectStartedViewOpacity = 1
            projectStartedView.configure(mode: .projectEmpty)
        default: break
        }
        func apply() {
            self.tasksToolbar.layer.opacity = tasksToolBarOpacity
            self.projectStartedView.layer.opacity = projectStartedViewOpacity
            self.newFormView.layer.opacity = newFormViewOpacity
            self.newFormViewBg.layer.opacity = newFormViewBgOpacity
            self.tasksWithDoneList.layer.opacity = tasksWithDoneListOpacity
        }
        if !didAppear {
            apply()
        } else {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                apply()
            }
        }
    }
    private func animateLayoutSubviews() {
        if didAppear {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                self.view.layoutSubviews()
            }
        }
    }
    
    private func projectPropertiesChanged() {
        topView.color = project.color
        topView.icon = project.icon
        tasksWithDoneList.sorting = project.sorting
        projectStartedView.configure(tintColor: project.color)
    }
    
    private func projectBindingSetup() {
        guard project.realm != nil else { return }
        let token = project.observe(on: .main) { [weak self] change in
            switch change {
            case .change(_, _):
                self?.projectPropertiesChanged()
                break
            case .deleted:
                break
            case let .error(error):
                print(error)
                break
            }
        }
        tokens.append(token)
    }
    
    // MARK: - Navigation Bar
    func setupNavigationBar() {
        addGestureToNavBar() // We add gesture to nav bar in order to check if topView icon was clicked
        navigationItem.rightBarButtonItem = actionsButton
        if isInbox {
            title = "Inbox"
        }
    }
    func addGestureToNavBar() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(navBarClicked))
        navigationController?.navigationBar.addGestureRecognizer(gestureRecognizer)
    }
    @objc func navBarClicked(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: nil)
        print("point: \(point) \(topView)")
        topView.navBarClicked(point: point)
    }
    private lazy var actionsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "dots"), style: .done, target: self, action: #selector(actionsButtonClicked))
        button.tintColor = UIColor(named: "TAHeading")!
        return button
    }()
    
    @objc func actionsButtonClicked() {
        var actions: [PopuptodoAction] = []
        if !state.isAddTask {
            let completeAllActive = project.tasks.contains { !$0.isDone }
            let completeAllImage = completeAllActive ? UIImage(named: "circle-check") : UIImage(named: "circle-check")?.withTintColor(UIColor(named: "TASubElement")!)
            let completeAllColor = completeAllActive ? UIColor(named: "TAHeading")! : UIColor(named: "TASubElement")!
            actions += [.init(title: "Complete All", image: completeAllImage, color: completeAllColor, isSelectable: completeAllActive, didSelect: { [weak self] _ in
                RealmProvider.main.safeWrite {
                    self?.project.tasks.forEach {
                        $0.isDone = true
                    }
                }
                self?.project.tasks.forEach {
                RealmStore.main.updateDateDependencies(in: $0)
                }
            })]
            let sortGrayImage = UIImage(named: "switch-vertical")?.withTintColor(UIColor(named: "TASubElement")!)
            let sortImage = UIImage(named: "switch-vertical")
            let sortedByName = project.sorting == .byName
            actions += [.init(title: "Sort by name", image: sortedByName ? sortImage : sortGrayImage, color: UIColor(named: "TAHeading")!, isSelectable: !sortedByName, didSelect: { [weak self] (_) in
                RealmProvider.main.safeWrite {
                    self?.project.sorting = .byName
                }
            })]
            let sortedByCreated = project.sorting == .byCreatedAt
            actions += [.init(title: "Sort by created", image: sortedByCreated ? sortImage : sortGrayImage, color: UIColor(named: "TAHeading")!, isSelectable: !sortedByCreated, didSelect: { [weak self] (_) in
                RealmProvider.main.safeWrite {
                    self?.project.sorting = .byCreatedAt
                }
            })]
            let sortedByPriority = project.sorting == .byPriority
            actions += [.init(title: "Sort by priority", image: sortedByPriority ? sortImage : sortGrayImage, color: UIColor(named: "TAHeading")!, isSelectable: !sortedByPriority, didSelect: { [weak self] _ in
                RealmProvider.main.safeWrite {
                    self?.project.sorting = .byPriority
                }
            })]
            let deleteCompletedAllActive = project.tasks.contains { $0.isDone }
            let deleteCompletedAllImage = deleteCompletedAllActive ? UIImage(named: "checks") : UIImage(named: "checks")?.withTintColor(UIColor(named: "TASubElement")!)
            let deleteCompletedAllColor = deleteCompletedAllActive ? UIColor(named: "TAHeading")! : UIColor(named: "TASubElement")!

            actions += [.init(title: "Delete Completed", image: deleteCompletedAllImage, color: deleteCompletedAllColor, isSelectable: deleteCompletedAllActive, didSelect: { [weak self] _ in
                let allTasksId = self?.project.tasks.filter { $0.isDone }.map { $0.id } ?? []
                guard !allTasksId.isEmpty else { return }
                let projectId = self?.project.id ?? ""
                allTasksId.forEach { taskId in
                    DBHelper.safeArchive(taskId: taskId, projectId: projectId)
                }
                self?.showBottomMessage(type: .allTasksDeleted) {
                    allTasksId.forEach { taskId in
                        DBHelper.safeUnarchive(taskId: taskId)
                    }
                }
            })]
            if project.id != Constants.inboxId {
                actions += [.init(title: "Delete Project", image: UIImage(named: "trash"), color: UIColor(named: "TAHeading")!, didSelect: { [weak self] handler in
                    self?.deleteProjectClicked()
                })]
            }
        }
        guard !actions.isEmpty else { return }
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: actionsButton, actions: actions)
        popMenu.shouldDismissOnSelection = true
        popMenu.appearance = .appAppearance
        present(popMenu, animated: true, completion: {
            print("didComplete")
        })
    }
    
    func deleteProjectClicked() {
        print("clicked")
        
        guard !self.project.tasks.isEmpty else {
            self.deleteProject()
            return
        }
        let alertVc = UIAlertController(title: "Delete Project", message: "Project '\(project.name)' will be removed", preferredStyle: .alert)
        alertVc.addAction(.init(title: "Delete all", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.deleteProject()
        }))
        alertVc.addAction(.init(title: "Delete and Archive", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.project.tasks.forEach {
                DBHelper.safeArchive(taskId: $0.id, projectId: self.project.id)
            }
            self.deleteProject()
        }))
        alertVc.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
        }))
        self.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.present(alertVc, animated: true, completion: nil)
        })
    }
    
    func deleteProject() {
        tokens = []
        self.project.tasks.forEach { task in
            Notifications.shared.removeNotifications(id: task.id)
        }
        RealmProvider.main.safeWrite {
            RealmProvider.main.realm.cascadeDelete(self.project)
        }
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - TOP VIEW
    private func topViewSetup() {
        guard !isInbox else { return }
        view.layout(topView).leading(13).trailing(13).topSafe()
        topView.shouldLayoutSubviews = { [weak self] in
            self?.view.layoutSubviews()
        }
        topView.addShadowFromOutside()
    }
    lazy var topView = ProjectDetailsTop(
        color: .hex("#FF9900"),
        projectName: project.name,
        icon: .text(getRandomEmoji()),
        onProjectNameChanged: { [weak self] newName in
            RealmProvider.main.safeWrite {
                self?.project.name = newName
            }
        },
        onProjectDescriptionChanged: { [weak self] newDescription in
            RealmProvider.main.safeWrite {
                self?.project.notes = newDescription
            }
        },
        colorSelection: { [weak self] sourceView, selectedColor in
            self?.colorSelection(sourceView, selectedColor)
        },
        iconSelected: { [weak self] in
            self?.router.openIconPicker(onDone: { selected in
                RealmProvider.main.safeWrite {
                    self?.project.icon = Icon.text(selected)
                }
            })
        },
        shouldAnimate: { [weak self] in
            return self?.didAppear ?? false
        })
    private func colorSelection(_ sourceView: UIView, _ selectedColor: UIColor) {
        let colorPicker = ColorPicker(
            viewSource: sourceView,
            selectedColor: selectedColor,
            onColorSelection: { [weak self] color, picker in
                RealmProvider.main.safeWrite {
                    self?.project.color = color
                }
                picker.shouldDismissAnimated()
            })
        colorPicker.shouldPurposelyAnimateViewBackgroundColor = true
        addChildPresent(colorPicker)
        colorPicker.shouldDismiss = { [weak colorPicker] in
            colorPicker?.addChildDismiss()
        }
    }
    
    // MARK: - Toolbar VIEW
    private func toolbarViewSetup() {
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(Constants.vcMinBottomPadding)
        tasksToolbar.onClick = { [weak self] in
            self?.state = .addTask(.init(priority: .none, name: "", description: "", tags: [], date: nil))
        }
    }
    private lazy var tasksToolbar = AllTasksToolbar()
    
    // MARK: - ProjectStarted VIEW
    private func projectStartedViewSetup() {
        if !isInbox {
            view.layout(projectStartedView).centerX().centerY().priority(749).leading(47).trailing(47).top(topView.anchor.bottom, 20) { _, _ in .greaterThanOrEqual }
            view.bringSubviewToFront(topView)
        } else {
            view.layout(projectStartedView).topSafe(0.065 * UIScreen.main.bounds.height).leading(47).trailing(47)
        }
    }
    private lazy var projectStartedView = ProjectStartedView(mode: .started)
    
    // MARK: - ProjectNewTaskForm VIEW
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
        state = .emptyOrList
    }
    private let newFormViewBg: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TABackground")!.withAlphaComponent(0.5)
        return view
    }()
    private lazy var newFormView = ProjectNewTaskForm(
        onCalendarClicked: { [weak self] _ in
            guard let self = self else { return }
            guard var addTask = self.state.addTaskModel else { return }
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
                                self?.state = .addTask(addTask)
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
            guard var addTask = self.state.addTaskModel else { return }
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
                        self.state = .addTask(addTask)
                    case let .new(tagName) where !addTask.tags.contains(tagName):
                        addTask.tags.append(tagName)
                        self.state = .addTask(addTask)
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
            guard var addTask = self.state.addTaskModel else { return }
            let tags = RealmProvider.main.realm.objects(RlmTag.self).filter { tag in addTask.tags.contains(where: { $0 == tag.name }) }
            self.router.openAllTags(mode: .selection(selected: Array(tags), { [weak self] selected in
                addTask.tags = ModelFormatt.tagsSorted(tags: selected).map { $0.name }
                self?.state = .addTask(addTask)
            }))
        },
        shouldAnimate: { [weak self] in self?.didAppear ?? false },
        shouldCreateTask: { [weak self] taskModel in
            self?.shouldCreateTask(task: taskModel)
        })
    
    func showPriorityPicker(sourceView: UIView) {
        let prevFirstResponder = self.getFirstResponder()
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "High Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.state.addTaskModel else { return }
                                addTask.priority = .high
                                self?.state = .addTask(addTask)
                            }),
            PopuptodoAction(title: "Medium Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.state.addTaskModel else { return }
                                addTask.priority = .medium
                                self?.state = .addTask(addTask)
                            }),
            PopuptodoAction(title: "Low Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.state.addTaskModel else { return }
                                addTask.priority = .low
                                self?.state = .addTask(addTask)
                            }),
            PopuptodoAction(title: "No Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTask = self?.state.addTaskModel else { return }
                                addTask.priority = .none
                                self?.state = .addTask(addTask)
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
        
    func newAddTask(addTask: ProjectDetailsTaskCreateModel) {
        state = .addTask(addTask)
    }
    
    func shouldCreateTask(task: ProjectDetailsTaskCreateModel) {
        let rlmTags = RealmProvider.main.realm.objects(RlmTag.self).filter { tag in task.tags.contains(where: { tag.name == $0 }) }
        let rlmTask = RlmTask(name: task.name, taskDescription: task.description, priority: task.priority, isDone: false, date: RlmTaskDate(date: task.date, reminder: task.reminder, repeat: task.repeatt), createdAt: Date())
        rlmTask.tags.append(objectsIn: rlmTags)
        RealmProvider.main.safeWrite {
            project.tasks.append(rlmTask)
        }
        RealmStore.main.updateDateDependencies(in: rlmTask)
        state = .addTask(.init(priority: .none, name: "", description: "", tags: [], date: nil))
        newFormView.resetView()
    }

        
    // MARK: - TasksWithDoneList VIEW
    private let __tasksSubject = PublishSubject<[RlmTask]>()
    private func tasksWithDoneListSetup() {
        if !isInbox {
            view.layout(tasksWithDoneList).top(topView.anchor.bottom).leading(13).trailing(13).bottom()
            view.bringSubviewToFront(topView)
        } else {
            view.layout(tasksWithDoneList).topSafe(0).leading(13).trailing(13).bottom()
        }
        tasksWithDoneList.contentInsets = UIEdgeInsets(top: isInbox ? 0 : 13 + 7, left: 0, bottom: 110, right: 0)
        __tasksSubject
            .bind(to: tasksWithDoneList.itemsInput)
            .disposed(by: bag)
        guard project.realm != nil else { return }
        let token = project.tasks.observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: _, insertions: _, modifications: _):
                self.__tasksSubject.onNext(Array(projects))
            case let .initial(projects):
                self.__tasksSubject.onNext(Array(projects))
            case let .error(error):
                print(error)
            }
        }
        tokens.append(token)
    }
    private lazy var tasksWithDoneList = TasksWithDoneList(
        onSelected: { [weak self] task in
            guard let self = self else { return }
            self.router.openTaskDetails(task)
        }, onChangeIsDone: { task in
            RealmProvider.main.safeWrite {
                task.isDone.toggle()
            }
            RealmStore.main.updateDateDependencies(in: task)
        }, shouldDelete: { [weak self] task in
            guard let self = self else { return }
            let taskId = task.id
            DBHelper.safeArchive(taskId: taskId, projectId: self.project.id)
            self.showBottomMessage(type: .taskDeleted, onClicked: {
                DBHelper.safeUnarchive(taskId: taskId)
            })
        }, shouldLayoutSevenPointsHigher: !isInbox)
    
    // MARK: - Util funcs
    func getFirstResponder() -> UIView? {
        if let firstResponder = newFormView.getFirstResponder() {
            return firstResponder
        }
        return nil
    }
    
    func showBottomMessage(type: BottomMessage.MessageType, onClicked: @escaping () -> Void) {
        let bottomMessage = BottomMessage.create(messageType: type, onClicked: onClicked)
        view.addSubview(bottomMessage)
        let height: CGFloat = !self.tasksToolbar.isHidden ?
            view.frame.height - tasksToolbar.frame.minY + 30 :
            self.view.safeAreaInsets.bottom + 15
        bottomMessage.show(height)
    }
    
}

extension ProjectDetailsVc {
    enum PrScreenState {
        case new
        case empty
        case addTask(ProjectDetailsTaskCreateModel)
        case list
        case emptyOrList
        case startAddTask
        
        var addTaskModel: ProjectDetailsTaskCreateModel? {
            switch self {
            case let .addTask(task): return task
            default: return nil
            }
        }
        var isAddTask: Bool {
            switch self {
            case .addTask(_): return true
            default: return false
            }
        }
    }
}
