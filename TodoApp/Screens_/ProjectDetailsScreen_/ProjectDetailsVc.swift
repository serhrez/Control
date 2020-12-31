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
    private var project: RlmProject
    private var isInbox: Bool { project.name == "Inbox" }
    private var tokens: [NotificationToken] = []
    private var shouldChangeHeightByKeyboardChange = true
    private let bag = DisposeBag()
    private let shouldPopTwo: Bool
    let trashTextField = TrashTextField()
    init(project: RlmProject, state: PrScreenState, shouldPopTwo: Bool = false) {
        self.project = project
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
        view.backgroundColor = .hex("#F6F6F3")
        projectBindingSetup()
        projectStartedViewSetup()
        topViewSetup()
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
            } : nil)
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        self.newFormView.didAppear()
        self.view.layoutSubviews()
    }
    
    func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [unowned self] options in
                guard self.shouldChangeHeightByKeyboardChange else { return }
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                if self.state.isAddTask && height < 100 { return }
                previousHeight = height
                newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                UIView.animate(withDuration: 0.5) {
                    self.animateLayoutSubviews()
                }
//                UIView.animate(withDuration: 0.5) {
//                    self.view.layoutSubviews()
//                }
            }
            .on(event: .willHide) { [unowned self] options in
                guard self.shouldChangeHeightByKeyboardChange else { return }
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                if self.state.isAddTask && height < 100 { return }
                previousHeight = height
                newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.animateLayoutSubviews()
                }
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
            newFormView.tags = newTask.tags
            return
        case (_, .list):
            tasksWithDoneListOpacity = 1
            tasksToolBarOpacity = 1
            break
        case (_, .new):
            projectStartedViewOpacity = 1
            tasksToolBarOpacity = 1
        case (_, .empty):
            tasksToolBarOpacity = 1
            break
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
            UIView.animate(withDuration: 0.25) {
                apply()
            } completion: { _ in
                
            }
        }
//        if oldState != newState && newState ==
    }
    private func animateLayoutSubviews() {
        if didAppear {
            UIView.animate(withDuration: 0.5) {
                self.view.layoutSubviews()
            }
        }
    }
    
    private func projectPropertiesChanged() {
        topView.color = project.color
        topView.icon = project.icon
    }
    
    private func projectBindingSetup() {
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
        button.tintColor = .hex("#242424")
        return button
    }()
    
    @objc func actionsButtonClicked() {
        var actions: [PopuptodoAction] = []
        if case .list = state {
            actions += [.init(title: "Delete all done tasks", image: UIImage(named: "plus"), color: .hex("#242424"), didSelect: { _ in
                
            })]
        }
        guard !actions.isEmpty else { return }
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: actionsButton, actions: actions)
        popMenu.shouldDismissOnSelection = false
        popMenu.appearance = .appAppearance
        present(popMenu, animated: true)
    }
    
    // MARK: - TOP VIEW
    private func topViewSetup() {
        guard !isInbox else { return }
        view.layout(topView).leading(13).trailing(13).topSafe()
        topView.shouldLayoutSubviews = view.layoutSubviews
        topView.addShadowFromOutside()
    }
    lazy var topView = ProjectDetailsTop(
        color: .hex("#FF9900"),
        projectName: project.name,
        projectDescription: project.notes,
        icon: .text("🚒"),
        onProjectNameChanged: { [weak self] newName in
            _ = try! RealmProvider.main.realm.write {
                self?.project.name = newName
            }
        },
        onProjectDescriptionChanged: { [weak self] newDescription in
            _ = try! RealmProvider.main.realm.write {
                self?.project.notes = newDescription
            }
        },
        colorSelection: colorSelection,
        iconSelected: { [weak self] in
            self?.router.openIconPicker(onDone: { selected in
                _ = try! RealmProvider.main.realm.write {
                    self?.project.icon = Icon.text(selected)
                }
            })
        },
        shouldAnimate: { [unowned self] in self.didAppear })
    private func colorSelection(_ sourceView: UIView, _ selectedColor: UIColor) {
        let colorPicker = ColorPicker(
            viewSource: sourceView,
            selectedColor: selectedColor,
            onColorSelection: { [weak self] color, picker in
                _ = try! RealmProvider.main.realm.write {
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
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(30)
        tasksToolbar.onClick = { [weak self] in
            self?.state = .addTask(.init(priority: .none, name: "", description: "", tags: [], date: nil))
        }
    }
    private lazy var tasksToolbar = AllTasksToolbar()
    
    // MARK: - ProjectStarted VIEW
    private func projectStartedViewSetup() {
        view.layout(projectStartedView).center().leading(47).trailing(47)
    }
    private lazy var projectStartedView = ProjectStartedView()
    
    // MARK: - ProjectNewTaskForm VIEW
    private func projectNewTaskViewSetup() {
        
        view.layout(newFormViewBg).edges()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(newFormViewBgTapped))
        newFormViewBg.addGestureRecognizer(tapGesture)
        view.layout(newFormView).leading().trailing().topSafe(30) { _, _ in .greaterThanOrEqual }
        newFormView.shouldLayoutSubviews = view.layoutSubviews
        newFormView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    @objc func newFormViewBgTapped() {
        state = .emptyOrList
    }
    private let newFormViewBg: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#f6f6f3").withAlphaComponent(0.5)
        return view
    }()
    private lazy var newFormView = ProjectNewTaskForm(
        onCalendarClicked: { [unowned self] _ in
            guard var addTask = self.state.addTaskModel else { return }
            self.router.openDateVc(reminder: addTask.reminder, repeat: addTask.repeatt, date: addTask.date) { [weak self] (date, reminder, repeatt) in
                addTask.date = date
                addTask.reminder = reminder
                addTask.repeatt = repeatt
                self?.state = .addTask(addTask)
            }
        },
        onTagClicked: { [unowned self] sourceView in
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
                            _ = try! RealmProvider.main.realm.write {
                                RealmProvider.main.realm.add(RlmTag(name: tagName))
                            }
                        }
                    default: break
                    }
                })
            self.addChildPresent(tagPicker)
            tagPicker.becomeFirstResponder()
//            self.trashTextField.becomeFirstResponder()
        },
        onPriorityClicked: showPriorityPicker,
        onTagPlusClicked: { [unowned self] in
            guard var addTask = self.state.addTaskModel else { return }
            let tags = RealmProvider.main.realm.objects(RlmTag.self).filter { tag in addTask.tags.contains(where: { $0 == tag.name }) }
            self.router.openAllTags(mode: .selection(selected: Array(tags), { selected in
                addTask.tags = ModelFormatt.tagsSorted(tags: selected).map { $0.name }
                self.state = .addTask(addTask)
            }))
        },
        shouldAnimate: { [unowned self] in self.didAppear },
        shouldCreateTask: shouldCreateTask)
    
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
                            })
        ]
        actions[0].imageTintColor = .hex("#EF4439")
        actions[1].imageTintColor = .hex("#FF9900")
        actions[2].imageTintColor = .hex("#447BFE")
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
        
    func newAddTask(addTask: ProjectDetailsTaskCreateModel) {
        state = .addTask(addTask)
    }
    
    func shouldCreateTask(task: ProjectDetailsTaskCreateModel) {
        let rlmTags = RealmProvider.main.realm.objects(RlmTag.self).filter { tag in task.tags.contains(where: { tag.name == $0 }) }
        let rlmTask = RlmTask(name: task.name, taskDescription: task.description, priority: task.priority, isDone: false, date: RlmTaskDate(date: task.date, reminder: task.reminder, repeat: task.repeatt), createdAt: Date())
        rlmTask.tags.append(objectsIn: rlmTags)
        _ = try! RealmProvider.main.realm.write {
            project.tasks.append(rlmTask)
        }
        state = .list
    }

        
    // MARK: - TasksWithDoneList VIEW
    private let __tasksSubject = PublishSubject<[RlmTask]>()
    private func tasksWithDoneListSetup() {
        if !isInbox {
            view.layout(tasksWithDoneList).top(topView.anchor.bottom, -10).leading(13).trailing(13).bottom()
            view.bringSubviewToFront(topView)
        } else {
            view.layout(tasksWithDoneList).topSafe(20).leading(13).trailing(13).bottom()
        }
        tasksWithDoneList.contentInsets = UIEdgeInsets(top: isInbox ? 0 : 13 + 10, left: 0, bottom: 110, right: 0)
        __tasksSubject
            .bind(to: tasksWithDoneList.itemsInput)
            .disposed(by: bag)
        let token = project.tasks.observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: _, insertions: _, modifications: _):
                self.__tasksSubject.onNext(Array(projects.sorted(byKeyPath: "createdAt")))
            case let .initial(projects):
                self.__tasksSubject.onNext(Array(projects.sorted(byKeyPath: "createdAt")))
            case let .error(error):
                print(error)
            }
        }
        tokens.append(token)
    }
    private lazy var tasksWithDoneList = TasksWithDoneList(
        onSelected: { [unowned self] task in
            self.router.openTaskDetails(task)
        }, shouldDelete: { [unowned self] task in
            _ = try! RealmProvider.main.realm.write {
                RealmProvider.main.realm.delete(task)
            }
        })
    
    // MARK: - Util funcs
    func getFirstResponder() -> UIView? {
        if let firstResponder = newFormView.getFirstResponder() {
            return firstResponder
        }
        return nil
    }
    
    var didDisappear: () -> Void = { }

    deinit {
        didDisappear()
    }
}

extension ProjectDetailsVc {
    enum PrScreenState {
        case new
        case empty
        case addTask(ProjectDetailsTaskCreateModel)
        case list
        case emptyOrList
        
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

extension ProjectDetailsVc: AppNavigationRouterDelegate { }
