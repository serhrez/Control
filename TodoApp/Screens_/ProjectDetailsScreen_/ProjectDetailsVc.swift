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
    private var didAppear: Bool = false
    private let keyboard = Typist()
    private var _oldState: PrScreenState = .emptyOrList 
    private var state: PrScreenState = .emptyOrList {
        didSet {
            changeState(oldState: _oldState, newState: state)
            _oldState = state
        }
    }
    private var project: RlmProject
    private var tokens: [NotificationToken] = []
    private let bag = DisposeBag()
    private let trashTextField = TrashTextField()
    init(project: RlmProject) {
        self.project = project
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .hex("#F6F6F3")
        projectBindingSetup()
        topViewSetup()
        projectStartedViewSetup()
        projectNewTaskViewSetup()
        tasksWithDoneListSetup()
        toolbarViewSetup()
        setupKeyboard()
        self.view.addSubview(trashTextField)
        state = .emptyOrList
        projectPropertiesChanged() // Init state
        applySharedNavigationBarAppearance()
        addGestureToNavBar()
    }
    
    // We add gesture to nav bar in order to check if topView icon was clicked
    func addGestureToNavBar() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(navBarClicked))
        navigationController?.navigationBar.addGestureRecognizer(gestureRecognizer)
    }
    @objc func navBarClicked(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: nil)
        print("point: \(point) \(topView)")
        topView.navBarClicked(point: point)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        self.newFormView.didAppear()
        self.view.layoutSubviews()
        self.view.layout(tasksToolbar).bottomSafe(30)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) {
            self.topView.addShadowFromOutside()
            self.view.layoutSubviews()
        }
    }
    
    func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                if self.state.isAddTask && height < 100 { return }
                previousHeight = height
                newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutSubviews()
                }
            }
            .on(event: .willHide) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                if self.state.isAddTask && height < 100 { return }
                previousHeight = height
                newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutSubviews()
                }
            }
            .start()

    }
    
    private func changeState(oldState: PrScreenState, newState newStatex: PrScreenState) {
        var newState = newStatex
        if case .emptyOrList = newState {
            newState = project.tasks.isEmpty ? .empty : .list
        }
        
        // Changing state
        var tasksToolBarOpacity: Float = 0
        var projectStartedViewOpacity: Float = 0
        var newFormViewOpacity: Float = 0
        var tasksWithDoneListOpacity: Float = 0
        var animationCompletion: (() -> Void)?
        // Pre change state
        switch (oldState, newState) {
        case (.addTask(_), _):
            newFormView.getFirstResponder()?.resignFirstResponder()
        default: break
        }
        // Changing state
        switch (oldState, newState) {
        case (_, .addTask(_)) where !oldState.isAddTask:
            newFormViewOpacity = 1
            animationCompletion = { _ = self.newFormView.becomeFirstResponder() }
        case let (.addTask(_), .addTask(newTask)):
            newFormView.priority = newTask.priority
            newFormView.date = (newTask.date, newTask.reminder, newTask.repeatt)
            newFormView.tags = newTask.tags
            return
        case (_, .list):
            tasksWithDoneListOpacity = 1
            tasksToolBarOpacity = 1
            break
        case (_, .empty):
            projectStartedViewOpacity = 1
            tasksToolBarOpacity = 1
        default: break
        }
        func apply() {
            self.tasksToolbar.layer.opacity = tasksToolBarOpacity
            self.projectStartedView.layer.opacity = projectStartedViewOpacity
            self.newFormView.layer.opacity = newFormViewOpacity
            self.tasksWithDoneList.layer.opacity = tasksWithDoneListOpacity
        }
        if !didAppear {
            apply()
            animationCompletion?()
        } else {
            UIView.animate(withDuration: 0.5) {
                apply()
            } completion: { _ in
                animationCompletion?()
            }
        }
//        if oldState != newState && newState ==
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
    
    // MARK: - TOP VIEW
    private func topViewSetup() {
        view.layout(topView).leading(13).trailing(13).topSafe()
        topView.shouldLayoutSubviews = view.layoutSubviews
        newFormView.shouldLayoutSubviews = view.layoutSubviews
    }
    lazy var topView = ProjectDetailsTop(
        color: .hex("#FF9900"),
        projectName: "fewfgw",
        projectDescription: "gewgqw",
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
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(-AllTasksToolbar.estimatedHeight)
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
        view.layout(newFormView).leading().trailing()
        newFormView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    private lazy var newFormView = ProjectNewTaskForm(
        onCalendarClicked: { [unowned self] _ in
            guard var addTask = self.state.addTaskModel else { return }
            let vc = CalendarVc(viewModel: .init(reminder: addTask.reminder, repeat: addTask.repeatt, date: addTask.date), onDone: {
                addTask.date = $0
                addTask.reminder = $1
                addTask.repeatt = $2
                self.state = .addTask(addTask)
            })
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .overFullScreen
            self.present(nav, animated: true)
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
            self.trashTextField.becomeFirstResponder()
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
        shouldCreateTask: { [weak self] newTask in
            let rlmTask = RlmTask(name: newTask.name, taskDescription: newTask.description, isDone: false, date: RlmTaskDate(date: newTask.date, reminder: newTask.reminder, repeat: newTask.repeatt), createdAt: Date())
            _ = try! RealmProvider.main.realm.write {
                self?.project.tasks.append(rlmTask)
            }
            self?.state = .emptyOrList
        })
    
    var didDisappear: () -> Void = { }
    
    // MARK: - TasksWithDoneList VIEW
    private let __tasksSubject = PublishSubject<[RlmTask]>()
    private func tasksWithDoneListSetup() {
        view.layout(tasksWithDoneList).top(topView.anchor.bottom, 13).leading(13).trailing(13).bottom()
        tasksWithDoneList.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 110, right: 0)
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
    })
    
    // MARK: - Util funcs
    private func getFirstResponder() -> UIView? {
        if let firstResponder = newFormView.getFirstResponder() {
            return firstResponder
        }
        return nil
    }
    
    private func showPriorityPicker(sourceView: UIView) {
//        let task = viewModel.taskToAddComponents
        let prevFirstResponder = self.getFirstResponder()
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "High Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTaskModel = self?.state.addTaskModel else { return }
                                addTaskModel.priority = .high
                                self?.state = .addTask(addTaskModel)
                            }),
            PopuptodoAction(title: "Medium Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTaskModel = self?.state.addTaskModel else { return }
                                addTaskModel.priority = .medium
                                self?.state = .addTask(addTaskModel)
                            }),
            PopuptodoAction(title: "Low Priority",
                            image: UIImage(named: "flag")?.withRenderingMode(.alwaysTemplate),
                            didSelect: { [weak self] _ in
                                guard var addTaskModel = self?.state.addTaskModel else { return }
                                addTaskModel.priority = .low
                                self?.state = .addTask(addTaskModel)
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
    deinit {
        didDisappear()
    }
}

extension ProjectDetailsVc {
    enum PrScreenState {
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
